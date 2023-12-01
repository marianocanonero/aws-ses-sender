#!/bin/bash
# Version: 2
# Last Update: 2023.12.01
# Author: mariano.canonero@gmail.com / Mariano Canonero

#------------------------------------------------------------------------------
# HELP
#------------------------------------------------------------------------------

function usage() {
    echo "Usage: $0 [-h|--help ]
    [-s|--subject <string> subject/title for email ]
    [-f|--from <email> ]
    [-r|--receiver|--receivers <emails> coma separated emails ]
    [-b|--body <string> ]
    [-h|--html <html string> ]
    [-a|--attachment|--attachments <filename> coma separated filepaths ]
    [--aws-region <string> Change Default AWS Region ]
    [--aws_access_key_id <string> Change AWS Access Key ID ]
    [--aws_secret_access_key <string> Change AWS Secret Access Key ]
    " 1>&2;
    exit 1;
}

#------------------------------------------------------------------------------
# CHECK REQUIREMENTS
#------------------------------------------------------------------------------

function Error() {
    echo "Error: $1"
    exit
}

function checkRequirements() {

    which aws
    if [ $? -ne 0 ]; then
        Error "AWS Cli tool is installed"
    fi

    which base64
    if [ $? -ne 0 ]; then
        Error "base64 tool is installed"
    fi
}

checkRequirements

#------------------------------------------------------------------------------
# PARSE PARAMETERS
#------------------------------------------------------------------------------

while :
do
	case $1 in
		-h|-\?|--help)
			usage
			;;
		-s|--subject)
			SUBJECT=$2
			printf '%s: %s\n' "SUBJECT" "$SUBJECT"
			shift
			;;
		-f|--from)
			FROM=$2
			printf '%s: %s\n' "FROM" "$FROM"
			shift
			;;
		-r|--receiver|--receivers)
			RECVS=$2
			printf '%s: %s\n' "TO" "$RECVS"
			shift
			;;
		-b|--body)
			BODY="$2"
			printf '%s: %s\n' "BODY" "$BODY"
			BODY="$(echo "$BODY" | base64 -w 0)"
			shift
			;;
		-h|--html)
			HTML="$2"
			printf '%s: %s\n' "HTML" "$HTML"
			HTML="$(echo "$HTML" | base64 -w 0)"
			shift
			;;
		-a|--attachment)
			ATTACHMENT=$2
			printf '%s: %s\n' "ATTACHMENT" "$ATTACHMENT"
			IFS=',' read -r -a ATTACHMENT_ARRAY <<< "$ATTACHMENT"
			shift
			;;
		--aws-region)
			export AWS_DEFAULT_REGION=$2
			shift
			;;
		--aws_access_key_id)
			export AWS_ACCESS_KEY_ID=$2
			shift
			;;
		--aws_secret_access_key)
			export AWS_SECRET_ACCESS_KEY=$2
			shift
			;;
		*)  # Default case: No more options, so break out of the loop.
			break
	esac

	shift
done

#------------------------------------------------------------------------------
# INITIALIZE BLANK TEMPLATE
#------------------------------------------------------------------------------

mkdir -p ses-email-tmp
TEMPLATE="ses-email-template.json"
TMPFILE="ses-email-tmp/ses-$(date +"%Y%m%d_%H%M%S")"
cp $TEMPLATE $TMPFILE

#------------------------------------------------------------------------------
# POPULATE TEMPLATE
#------------------------------------------------------------------------------

# Required Fields
sed -i -e "s/{SUBJECT}/$SUBJECT/g" $TMPFILE
sed -i -e "s/{FROM}/$FROM/g" $TMPFILE
sed -i -e "s/{RECVS}/$RECVS/g" $TMPFILE

# Define Body
if [[ -n ${HTML} && -n ${BODY} ]]; then
	TEXT_BODY+="Content-Type: text/plain\\\\nContent-Transfer-Encoding: base64\\\\n\\\\n$BODY"
	HTML_BODY+="Content-Type: text/html\\\\nContent-Transfer-Encoding: base64\\\\n\\\\n$HTML"
	BODY="$TEXT_BODY\\\\n\\\\n--SubNextPart\\\\n$HTML_BODY"
elif [[ -n ${BODY} ]]; then
	BODY=="Content-Type: text/plain\\\\nContent-Transfer-Encoding: base64\\\\n\\\\n$BODY"
elif [[ -n ${HTML} ]]; then
	BODY="Content-Type: text/html\\\\nContent-Transfer-Encoding: base64\\\\n\\\\n$HTML"
else
	echo "ERROR - Missing Body"
	exit 1
fi

sed -i -e "s#{BODY}#$BODY#g" $TMPFILE

# Attachments
ATTACHMENTS="";
if [[ -n ${ATTACHMENT} ]]; then
	for ATTACHMENT_PATH in "${ATTACHMENT_ARRAY[@]}"; 
	do
		FILENAME=$(basename "${ATTACHMENT_PATH%}")
		ATTACHMENT=`base64 -i -w 0 $ATTACHMENT_PATH`
		ATTACHMENTS+="\\\\n\\\\n--NextPart\\\\nContent-Type: text/plain;\\\\nContent-Disposition: attachment; filename=\\\\\"${FILENAME}\\\\\"\\\\nContent-Transfer-Encoding: base64\\\\n\\\\n$ATTACHMENT"
	done
fi
sed -i -e "s#{ATTACHMENTS}#$ATTACHMENTS#g" $TMPFILE

#------------------------------------------------------------------------------
# SEND EMAIL
#------------------------------------------------------------------------------

PATH=$PATH:/usr/local/bin
export PATH

AWS_CLI_VERSION=$(aws --version 2>&1 | cut -d " " -f1 | cut -d "/" -f2 | cut -d "." -f1)

if [[ $AWS_CLI_VERSION -eq 1 ]]; then
	echo "AWS_CLI_VERSION = 1"
	aws ses send-raw-email --raw-message file://$TMPFILE
elif [[ AWS_CLI_VERSION -eq 2 ]]; then
	echo "AWS_CLI_VERSION = 2"
	aws ses send-raw-email --cli-binary-format raw-in-base64-out --raw-message file://$TMPFILE
else
	echo "ERROR - AWS version not found"
fi

#------------------------------------------------------------------------------
