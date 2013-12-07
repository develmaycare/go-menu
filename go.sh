#! /bin/bash

###################################
# License
###################################

# Copyright (C) 2002-2013 F.S. Davis <consulting@fsdavis.com>. All rights
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

# Determine if dialog command is available.
function dialog_available()
{
    result=`which dialog`;
    if [[ $? > 0 ]];
        then echo "f"; return 1;
        else echo "t"; return 0;
    fi;
} # dialog_available

# Find the user's choice and return the connection string.
function find_choice()
{
    line_number=1;
    for line in `cat $resources_file`
    do

        c="${line:0:1}";
        if [[ $c == "#" ]]; then continue; fi;

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

        protocol='ssh';
        protocol_override=`echo "$line" | awk -F ',' '{print $7}'`;
        if [[ -n "$protocol_override" ]]; then protocol=$protocol_override; fi;

        key_file='';
        key_file=`echo "$line" | awk -F ',' '{print $8}'`;

        if [[ $choice == $name || $choice == $line_number ]]; then

            if [[ $host == "HERE" ]]; then
                echo "You are here!";
                quit $EXIT_NORMAL;
            fi;

            export PROMPT_COMMAND='echo -ne "\033]0;'$name'\007"'

            case $protocol in
                ssh)
                    cmd="ssh -p $port";
                    if [[ -n "$key_file" ]]; then 
                        if [[ ! -f $key_file ]]; then key_file=~/.ssh/$key_file; fi;
                        cmd="$cmd -i $key_file";
                    fi;
                    cmd="$cmd $user@$host"
                ;;

                *)
                    echo "$protocol protocol not supported.";
                    quit $EXIT_OTHER;
                ;;
            esac

            echo "$cmd";
            return 0;

        fi;

        line_number=`expr $line_number + 1`;

    done

    echo "Something went wrong and the choice could not be found. Weird.";
    return 1;
} # find_choice

# Close the menu.
function footer()
{
    if [[ $dialog_enabled == "t" ]];
        then
            echo "        QUIT \"Leave the Go Menu\"\\" >> $DIALOG_SH;
            echo "    2> $CHOICE_FILE" >> $DIALOG_SH;
            chmod 755 $DIALOG_SH;
        else
            echo "" >> $TEMP_FILE;
            echo "Q)UIT" >> $TEMP_FILE;
            echo "" >> $TEMP_FILE;
    fi;
} # footer

# Create the menu title.
function header()
{
    local title=$1;
    if [[ $dialog_enabled == "t" ]]; 
        then
            echo 'dialog --backtitle "Go Menu" --title "Go Menu"\' > $DIALOG_SH;
            echo "    --menu \"Select from the resources below:\" $dialog_height $dialog_width $dialog_menu_height\\" >> $DIALOG_SH;
            echo "        FILTER\"Filter the menu.\"\\" >> $DIALOG_SH;
        else
            echo "------------------------------------------------------------------------------" >> $TEMP_FILE;
            echo "$title" >> $TEMP_FILE;
            echo "------------------------------------------------------------------------------" >> $TEMP_FILE;
            echo "F)ILTER" >> $TEMP_FILE;
            echo "" >> $TEMP_FILE;
    fi;
} # header

# Create the user's gomenu directory and initial preferences.
function init()
{
    if [[ -d ~/.gomenu ]]; then return 0; fi;

    dialog_enabled=`dialog_available`;

    mkdir ~/.gomenu;
    cat > ~/.gomenu/preferences.cfg << EOF
# Indicates whether the dialog command should be used by default.
dialog_enabled="$dialog_enabled";

# Control the dimensions of dialog menus.
#dialog_height=25;
#dialog_width=79;
#dialog_menu_height=20;

# Used to cause the Go Menu should first connect to another server.
# use_proxy="ssh://user@example.com:22";
EOF

    cat > ~/.gomenu/resources.csv << EOF
# <Name>, <Organization>, <Comment>, <Host>, [Port], [User], [Protocol], [Key File]
Example,FSD,This is an example.,example.com,2222,bob,ssh,~/.ssh/example_rsa
EOF
} # init

# Clean up and exit.
function quit()
{
    local exit_code=$1;
    if [[ -z "$exit_code" ]]; then exit_code=0; fi;

    for f in $CHOICE_FILE $DIALOG_SH $TEMP_FILE
    do
        if [[ -f $f ]]; then rm $f; fi;
    done

    exit $exit_code;
} # quit

# Create the menu items from CSV file.
function menu_items()
{
    local resources_file=$1;

    line_number=1;
    IFS="
";
    for line in `cat $resources_file`
    do
        c="${line:0:1}";
        if [[ $c == "#" ]]; then continue; fi;

        name='';
        name=`echo "$line" | awk -F ',' '{print $1}'`;
        organization='';
        organization=`echo "$line" | awk -F ',' '{print $2}'`;
        comment='';
        comment=`echo "$line" | awk -F ',' '{print $3}'`;
        host='';
        host=`echo "$line" | awk -F ',' '{print $4}'`;
        if [[ $dialog_enabled == "t" ]]; 
            then
                echo "        $name \"($organization) $comment - $host\"\\" >> $DIALOG_SH;
            else
                echo "$line_number) $name ($organization): $comment - $host" >> $TEMP_FILE;
        fi;
        line_number=`expr $line_number + 1`;
    done
} # menu_items


###################################
# Configuration
###################################

# Script information.
SCRIPT=`basename $0`;
DATE="2013-12-07";
VERSION="2.0.0-d";

# Dialog defaults.
dialog_enabled='t';
dialog_height=25;
dialog_width=79;
dialog_menu_height=20;

# Make the user's go directory as needed.
if [[ ! -d ~/.gomenu ]]; then init; fi;
source ~/.gomenu/preferences.cfg;

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

The go command reads resources from a text file located in one of the following
locations:

$HOME/.gomenu/resources.csv
/etc/gomenu/resources.csv
/opt/gomenu/resources.csv

These files are read in the order above. The valid columns are:

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

key_file - The SSH key file to use, if any. If given, your public key needs to
be in the authorized_keys of the user account on the host machine.

";

# Help and information.
if [[ $1 = '--help' ]]; then echo "$HELP"; quit $EXIT_NORMAL; fi;
if [[ $1 = '--version' ]]; then echo "$SCRIPT $VERSION ($DATE)"; quit $EXIT_NORMAL; fi;

###################################
# Arguments
###################################

resources_file='';

while getopts "f:hv" arg
do
    case $arg in
        f) resources_file=$OPTARG;;
        v) echo "$VERSION"; quit $EXIT_NORMAL;;
        h|*) echo "$SCRIPT [OPTIONS]"; quit $EXIT_NORMAL;;
    esac
done

# Make sure dialog is installed.
if [[ $dialog_enabled == "t" ]]; then
    if [[ `dialog_available` == "f" ]]; then
        echo "The dialog command does not appear to be installed. Change your preferences to use a text-driven menu.";
        quit $EXIT_ENVIRONMENT;
    fi;
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
    echo "No resources file could be found. It's too much. I can't go on.";
    quit $EXIT_ENVIRONMENT;
fi;

###################################
# Procedure
###################################

# Check for the news file.
news_file=~/.gomenu/news.txt;
if [[ -f $news_file ]]; then 
    if [[ $dialog_enabled == "t" ]]; 
        then
            echo -n 'dialog --backtitle "Go Menu" --title "Announcement"' > $DIALOG_SH;
            echo " --msgbox \"`cat $news_file`\" 20 30" >> $DIALOG_SH;
            chmod 755 $DIALOG_SH;
            $DIALOG_SH;
        else
            cat $new_file | more;
    fi;

    rm $news_file;
fi;

# Build the menu.
header "Go Menu";
menu_items $resources_file;
footer;

# Display the menu and capture the choice.
if [[ $dialog_enabled == "t" ]];
    then 
        $DIALOG_SH;
        if [[ $? = 1 ]]; 
            then choice='Q';
            else choice=`cat $CHOICE_FILE`; 
        fi;
    else
        cat $TEMP_FILE | more;
        echo -n "Your choice? ";
        read choice;
fi;

# Handle QUIT and Cancel choices. Also handle filtering.
case $choice in
    F|f)
        echo "TODO: Enable filtering.";
        quit $EXIT_OTHER;
    ;;
    Q|q)
        clear;
        echo "Goodbye, Mrs. Gloop! Adieu! Auvidersein! Gesundheit! Farewell!";
        quit $EXIT_NORMAL;
    ;;
esac

# Find the selected menu item.
find_choice $resources_file $choice;
cmd=`find_choice $resources_file $choice`;
if [[ $? -gt 0 ]]; then
    echo "$cmd";
    quit $EXIT_OTHER;
fi;

# Connect to the resource.
clear;
echo "Connecting to $host ...";
echo "$cmd":
$cmd;

if [[ $? -gt 0 ]]; then
    quit;
fi;

# Reload the menu.
clear;
$0;
quit $EXIT_OTHER;

########## ORIGINAL STUFF HERE ##########


