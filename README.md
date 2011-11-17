# Highrise Assist

highrise_assist is command line tool for 37signals' highrise.

## Description

If you are using http://highrisehq.com/, you defiantly can notice that there are some processes in your company, that doesn't feet to the functionality implemented by 37signals' team. Fortunately they have quite strong API, that can be used for custom purposes. In our company we have bunch of such customizations, that we have decided to group in to the gem and deliver to the community. An the first tool is companies and contacts export by tag (read more below). So highrise_assist is a command line set of tools, which let you do custom operations with your data in highrise. 

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

### Description

If you are the using highrise for sales, human resources or some other activities, one day you will want to export data from the system. Here is the original article http://bit.ly/sTQr1W, which is describing the process. It's quite easy and works fine, but with highrise_assistexport you can do much better. This tool introduce you possibility to export companies and contacts with all the hierarchy of data including emails, notes, comments, cases, deals and even attachments (with web console you just don't have such  possibility) in xml or yaml formats. It is possible to mark exact business objects with the tag and then just export them.

#### The use case 1:

As user of higrise
I want to archive old contacts and companies 
So that my list will be clean

Original help request: http://bit.ly/tIDlwk
What 37signals' team recommends is: "Have you considered adding a tag to those contacts called "archived"?"
With highrise_assistexport you can easily export all the data tagged as "archived", and than just remove data from the system.

#### The use case2:

As user of higrise
I want to export all my data including attachments
So that I can move data to the other management systems

With highrise_assistexport you can easily do this operation.

## Keep your higrise always clean!

### Synopsis

    $ highrise_assist export OPTIONS

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

