# AWS SES Sender

<div>
The <b>DEFINITIVE</b> solution for sending emails using <b>Amazon SES services</b> (Amazon Simple E-mail Services).
</div>
<br>
<div>
<b><u>Supports</u>:
    <lu>
        <li>Single and Multiple Receivers</li>
        <li>Text and HTML Body</li>
        <li>None, Single & Multiple Attachments</li>
    </lu>
</b>
</div>
</br>
<div>
It requires <b>AWS CLI</b> (installation instructions below).
</div>

## Table of Contents

1. [AWS CLI](#aws_cli)
    1. [Installation](#installation)
    2. [Configuration](#configuration)
2. [Usage](#usage)
3. [Commands](#commands)
    1. [Recipients](#recipients)
        1. [Single](#recipients_single)
        2. [Multiple](#recipients_multiple)
    2. [Body](#body)
        1. [Text](#body_text)
        2. [HTML](#body_html)
    3. [Attachments](#attachments)
        1. [None](#attachments_none)
        2. [Single](#attachments_single)
        3. [Multiple](#attachments_multiple)


## AWS CLI <a name="aws_cli"></a>

### Installation <a name="installation"></a>

There are many ways to install AWS CLI (Amazon Web Service Command Line Client) including using pip package manager, homebrew package manager (https://brew.sh/) or just downloading the raw executables (http://docs.aws.amazon.com/cli/latest/userguide/installing.html).

```bash
brew install awscli
```

```bash
pip3 install --upgrade --user awscli
```

### Configuration <a name="configuration"></a>

After installing <b>AWS CLI</b>, you must configure the credential file:

```bash
aws configure
```

## Usage <a name="usage"></a>

You can get help with -h or --help argument.

```bash
$ sh sender.sh -h

Usage: sender.sh 
    [-h|--help ]
    [-s|--subject <string> subject/title for email ]
    [-f|--from <email> ]
    [-r|--receiver|--receivers <emails> coma separated emails ]
    [-b|--body <string> ]
    [-h|--html <html string> ]
    [-a|--attachment|--attachments <filename> coma separated filepaths ]
    [--aws-region <string> Change Default AWS Region ]
    [--aws_access_key_id <string> Change AWS Access Key ID ]
    [--aws_secret_access_key <string> Change AWS Secret Access Key ]
```

## Commands <a name="commands"></a>

### Recipients <a name="recipients"></a>

#### Single <a name="recipientes_single"></a>
```bash
sh sender.sh -s "test single receiver" -f sender@domain.com -r receiver@domain.com -b "mail content"
```

#### Multiple  <a name="recipientes_multiple"></a>
```bash
sh sender.sh -s "test multiple receivers" -f sender@domain.com -r receiver@domain.com,receiver2@domain.com -b "mail content"
```

### Body <a name="body"></a>

#### Plain Text <a name="body_text"></a>
```bash
sh sender.sh -s "test text body" -f sender@domain.com -r receiver@domain.com -b "mail content"
```

#### HTML <a name="body_html"></a>
```bash
sh sender.sh -s "test html body" -f sender@domain.com -r receiver@domain.com -h "<html><head><style></style></head><body>mail content in html</body></html>"
```

### Attachments <a name="attachments"></a>

#### None <a name="attachments_none"></a>
```bash
sh sender.sh -s "test attachment" -f sender@domain.com -r receiver@domain.com -b "mail with single attachment content"
```

#### Single <a name="attachments_single"></a>
```bash
sh sender.sh -s "test attachment" -f sender@domain.com -r receiver@domain.com -b "mail with single attachment content" -a path/to/test.file
```

#### Multiple <a name="attachments_multiple"></a>
```bash
sh sender.sh -s "test multiple attachments" -f sender@domain.com -r receiver@domain.com -b "mail with mutiple attachments content" -a path/to/test.file,path/to/test2.file
```
