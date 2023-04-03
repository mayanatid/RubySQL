# Welcome to RubySQL
***

<p float="left">
<img src="https://thumbs.dreamstime.com/b/sql-icon-trendy-modern-flat-linear-vector-white-bac-background-thin-line-internet-security-networking-collection-130953272.jpg" width="150"> 

<img src="https://icon-library.com/images/ruby-icon-png/ruby-icon-png-18.jpg" width="150" display="inline"> 
</p>
## Overview
RubySQL is a command-line tool which executes basic SQL commands on .csv files. The following command patterns are available

* **SELELCT** [field1, field2, ...] **FROM** [filename.csv] **WHERE** [field_name = condition]
* **INSERT INTO** [filename.csv] **VALUES** (field1_val, field2_val, ...)
* **UPDATE** [filename.csv] **SET** [filed1 = val1, field2 = val2, ...] **WHERE** [field_name = condition]
* **DELETE FROM** [filename.csv] **WHERE** [field_name = condition]

## How it works
The application is implemented in Ruby and leverages two files: `my_sqlite_request.rb` (the "back-end") and `my_sqlite_cli.rb` (the "front-end"). A `MySqliteRequest` class handles the logic of processing requests and a `MySqliteCLI` class handles taking user input and displaying any results from queries.



## Installation
There is not installation required, only an up to date version of Ruby

## Usage
The program can be started from the root directory with 
```
ruby my_sqlite_cli.rb
```

### The Core Team


<span><i>Made at <a href='https://qwasar.io'>Qwasar SV -- Software Engineering School</a></i></span>
<span><img alt='Qwasar SV -- Software Engineering School's Logo' src='https://storage.googleapis.com/qwasar-public/qwasar-logo_50x50.png' width='20px'></span>
