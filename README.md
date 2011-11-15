# Highrise Assist

highrise_assist is command line for 37signals' highrise.

## Description

TODO

## Installation

    $ gem install highrise_assist

## Usage

    Usage: ./bin/highrise_assist COMMAND [options]

    Commands:
      * export - export next highrise items:
        * cases
        * deals
        * people
        * companies
        * emails
        * notes
        * comments
        * attachments

    Common options:
            --domain DOMAIN              highrise subdomain or full domain name
            --token TOKEN                highrise API authentication token

    Export options:
            --tag TAG                    filter items with given tag name
            --directory DIRECTORY        working directory
            --format FORMAT              data format (yaml,xml)
            --skip-attachments           don't download attachments
            --skip-cases                 don't export cases
            --skip-deals                 don't export deals
            --skip-notes                 don't export notes
            --skip-emails                don't export emails
            --skip-comments              don't export comments

    Misc options:
        -h, --help                       Show this message
        -v, --version                    Show version

## Export Command

### DESCRIPTION

TODO

### Synopsis

    $ highrise_assistexport OPTIONS

### Options

* _domain_ (required) is either your full highrise domain name or subdomain name.
* _token_ (required) is your API authentication token.
* _tag_ is tag name for entities associated with it.
* _directory_ - directory to store export data (default is highrise_data_YYYYMMDDHHMMSS)

### Example

    $ highrise_assist export \
      --domain MYSUBDOMAIN \
      --token 11111111111111111111111111111111 \
      --directory highrise_data \
      --tag old-clients \
      --format xml \
      --skip-attachments

Export result:

    $ tree --dirsfirst
    .
    ├── cases
    │   ├── case-573785-test-case
    │   │   ├── attachments
    │   │   │   └── 22039573-20111111-p7km4bk33ugutcrrb5mxxw7fjj.jpeg
    │   │   ├── case-573785-test-case.xml
    │   │   └── note-78169727-test.xml
    │   └── case-573786-what-is-highrise
    │       ├── attachments
    │       └── case-573786-what-is-highrise.xml
    ├── deals
    │   └── deal-1471928-test-deal
    │       ├── attachments
    │       ├── deal-1471928-test-deal.xml
    │       └── note-78499917.xml
    └── persons
        └── person-92632832-test-test
            ├── attachments
            ├── cases
            │   └── case-573785-test-case -> ../../../cases/case-573785-test-case
            ├── deals
            │   └── deal-1471928-test-deal -> ../../../deals/deal-1471928-test-deal
            └── person-92632832-test-test.xml

