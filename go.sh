#! /bin/bash

###################################
# License
###################################

# Copyright (C) 2002-2011 F.S. Davis <consulting@fsdavis.com>. All rights
# reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

###################################
# Functions
###################################

function cleanup()
{
    for f in $CHOICE_FILE $DIALOG_SH $TEMP_FILE
    do
        if [[ -f $f ]]; then rm $f; fi;
    done
}

###################################
# Configuration
###################################

# Script information.
SCRIPT=`basename $0`;
DATE="Nov 26, 2011";
VERSION="1.2.0-d";

# Dialog defaults.
dialog_height=30;
dialog_width=70;
dialog_menu_height=25;

# Exit codes.
EXIT_NORMAL=0;
EXIT_USAGE=1;
EXIT_ENVIRONMENT=2;
EXIT_OTHER=3;

# Temporary files.
CHOICE_FILE=~/.gomenu/choice.txt;
DIALOG_SH=~/.gomenu/dialog.sh;
TEMP_FILE="$SCRIPT".$$

###################################
# Help
###################################

HELP="
SUMMARY

Use a graphic interface to connect to various pre-defined server resources.

OPTIONS

-f <resources_file>
    Specify a file to use rather than accepting the default. See NOTES.

-h		
    Print help and exit.

--help
    Print more help and exit.

-v		
    Print version and exit.

--version
    Print full version and exit.

NOTES

The go command reads resources from a CSV file located in one of the following
locations:

$HOME/.gomenu/resources.csv
/etc/gomenu/resources.csv
/opt/gomenu/resources.csv

These files are read in the order above. The columns of the CSV are as follows:

name - The name of the resource. Required. Cannot contain a space.

organization - A short code or abbreviation representing the organization that
owns the resource. Required. Limited to 3 or 4 characters.

comment - A brief comment or description of the resource. Required. Limited to
about 30 characters.

host - The actual host name that is the target of the connection. Required.

port - TCP port. Required, but defaults to 22.

user - The user name for the connection. Optional. Defaults to `whoami`.

protocol - Not implemented. Defaults to ssh. This is a placeholder for possibly
implementing other protocols in the future.

Here some examples:

MsPiggy,ACME,Windows File Server,mspiggy.example.com
RedHat6,ABC,Web Server,redhat6.example.com,4894
Venus,ACME,Web Server,venus.example.com,4894,bob
";

# Help and information.
if [[ $1 = '--help' ]]; then echo "$HELP"; cleanup; exit $EXIT_NORMAL; fi;
if [[ $1 = '--version' ]]; then echo "$SCRIPT $VERSION ($DATE)"; cleanup; exit $EXIT_NORMAL; fi;

###################################
# Arguments
###################################

resources_file='';

while getopts "f:hv" arg
do
    case $arg in
        f) resources_file=$OPTARG;;
        v) echo "$VERSION"; cleanup; exit $EXIT_NORMAL;;
        h|*) echo "$SCRIPT [OPTIONS]"; cleanup; exit $EXIT_NORMAL;;
    esac
done

# Make sure dialog is installed.
result=`which dialog`;
if [[ $? > 0 ]]; then
    echo "The dialog command does not appear to be installed.";
    cleanup;
    exit $EXIT_ENVIRONMENT;
fi;

# Attempt to automatically find a resources configuration file if one hasn't
# been given.
if [[ -z "$resources_file" ]]; then
    for f in ~/.gomenu/resources.csv /etc/gomenu/resources.csv /opt/gomenu/resources.csv
    do
        if [[ -f $f ]]; then resources_file=$f; fi;
    done
fi;

# Give up if no resources file was found.
if [[ -z "$resources_file" ]]; then
    echo "No resources file could be found. I can't go on.";
    cleanup;
    exit $EXIT_ENVIRONMENT;
fi;

###################################
# Procedure
###################################

# Make the user's go directory as needed.
if [[ ! -d ~/.gomenu ]]; then mkdir ~/.gomenu; fi;

# Check for the news file.
news_file=~/.gomenu/news.txt;
if [[ -f $news_file ]]; then 
    echo -n 'dialog --backtitle "Go Menu" --title "Announcement"' > $DIALOG_SH;
    echo " --msgbox \"`cat $news_file`\" 20 30" >> $DIALOG_SH;
    chmod 755 $DIALOG_SH;
    $DIALOG_SH;
    rm $news_file;
fi;

# Start building the dialog script with the preamble below.
echo 'dialog --backtitle "Go Menu" --title "Go Menu"\' > $DIALOG_SH;
echo "    --menu \"Select from the resources below:\" $dialog_height $dialog_width $dialog_menu_height\\" >> $DIALOG_SH;

# Read the CSV file to build the menu portion of the dialog script.
IFS="
";
for line in `cat $resources_file`
do
    name='';
    name=`echo "$line" | awk -F ',' '{print $1}'`;
    organization='';
    organization=`echo "$line" | awk -F ',' '{print $2}'`;
    comment='';
    comment=`echo "$line" | awk -F ',' '{print $3}'`;
    host='';
    host=`echo "$line" | awk -F ',' '{print $4}'`;
    echo "        $name \"($organization) $comment - $host\"\\" >> $DIALOG_SH;
done

# Finish and execute the dialog script.
echo "        QUIT \"Leave the Go Menu\"\\" >> $DIALOG_SH;
echo "    2> $CHOICE_FILE" >> $DIALOG_SH;
chmod 755 $DIALOG_SH;
$DIALOG_SH;

if [[ $? = 1 ]]; 
    then choice='QUIT';
    else choice=`cat $CHOICE_FILE`; 
fi;

# Handle QUIT and Cancel choices.
if [[ $choice = 'QUIT' ]]; then 
    clear;
    cleanup;
    echo "Goodbye, Mrs. Gloop! Adieu! Auvidersein! Gesundheit! Farewell!";
    exit $EXIT_NORMAL;
fi;

# Connect to the resource.
for line in `cat $resources_file`
do
    name='';
    name=`echo "$line" | awk -F ',' '{print $1}'`;

    organization='';
    organization=`echo "$line" | awk -F ',' '{print $2}'`;

    comment='';
    comment=`echo "$line" | awk -F ',' '{print $3}'`;
    
    host='';
    host=`echo "$line" | awk -F ',' '{print $4}'`;

    port='22';
    port_override=`echo "$line" | awk -F ',' '{print $5}'`;
    if [[ -n "$port_override" ]]; then port=$port_override; fi;

    user=`whoami`;
    user_override=`echo "$line" | awk -F ',' '{print $6}'`;
    if [[ -n "$user_override" ]]; then user=$user_override; fi;

    pre_command='';
    pre_command=`echo "$line" | awk -F ',' '{print $7}'`;

    if [[ $choice == $name ]]; then
        if [[ $host == 'HERE' ]]; then
            echo "You are here!";
            cleanup;
            exit $EXIT_NORMAL;
        fi;

        export PROMPT_COMMAND='echo -ne "\033]0;'$name'\007"'

        connection="ssh://$user@$host:$port";
        echo "Connecting to $connection ...";
        ssh -p $port $user@$host;
    fi;
done

# Reload the menu.
$0;
