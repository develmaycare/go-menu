



help="
    key:value
    ---

The --- is used as a record separator.

    name:MsPiggy
    organization:ACME
    comment:Windows File Server
    host:mspiggy.example.com
    ---

    name:RedHat6
    organization:ABC
    comment:Web Server
    host:redhat6.example.com
    port:2222
    ---

    name:Venus
    organization:ACME
    comment:Web Server
    host:venus.example.com
    port:2222
    user:bob
    ---
";

# Find the user's choice and return the connection string.
function find_choice()
{
    local resources_file=$1;
    local choice=$2;

    item_number=1;
    IFS="
";

    for line in `cat $resources_file`
    do
        key=`echo $line | awk -F ":" '{print $1}'`;
        value=`echo $line | awk -F ":" '{print $2}'`;
        if [[ $key == "name" ]]; then
        fi;

    done

    key_file="";
    port="22";
    protocol="ssh";
    user=`whoami`;

    for line in `cat $resources_file`
    do
        # Reset defaults when a record separator is found.
        if [[ $line == "---" ]]; 
            then
                key_file="";
                port="22";
                protocol="ssh";
                user=`whoami`;
            else

                key=`echo $line | awk -F ":" '{print $1}'`;
                value=`echo $line | awk -F ":" '{print $2}'`;

                case $key in
                    h|host) host=$value;;
                    i|info|comment) comment=$value;;
                    k|key|key_file) key_file=$value;;
                    n|name) name=$value;;
                    o|org|organization) organization=$value;;
                    p|port) port=$value;;
                    protocol) protocol=$value;;
                    u|user) user=$value;;
                esac

                continue;
        fi;

        echo "$choice == $name || $choice == $item_number";

        if [[ $choice == $name || $choice == $item_number ]]; then
            if [[ $host == "HERE" ]]; then
                echo "You are here!";
                quit $EXIT_NORMAL;
            fi;

            export PROMPT_COMMAND='echo -ne "\033]0;'$name'\007"'

            case $protocol in
                ssh)
                    cmd="ssh -p $port";
                    if [[ -n "$key_file" ]]; then 
                        if [[ ! -f $key_file ]]; then key_file=~/$key_file; fi;
                        cmd="$cmd -i $key_file";
                    fi;
                    cmd="$cmd $protocol://$user@$host"
                ;;

                *)
                    echo "$protocol protocol not supported.";
                    return 1;
                ;;
            esac

            echo "$cmd";
            return 0;
        fi;

        item_number=`expr $item_number + 1`;
    done

    return 1;
} # find_choice

# Get the menu items.
function menu_items()
{
    local resources_file=$1;

    item_number=1;
    IFS="
";

    for line in `cat $resources_file`
    do

        if [[ $line != "---" ]]; then
            key=`echo $line | awk -F ":" '{print $1}'`;
            value=`echo $line | awk -F ":" '{print $2}'`;

            case $key in
                h|host) host=$value;;
                i|info|comment) comment=$value;;
                n|name) name=$value;;
                o|org|organization) organization=$value;;
            esac

            continue;
        fi;

        if [[ $dialog_enabled == "t" ]]; 
            then
                echo "        $name \"($organization) $comment - $host\"\\" >> $DIALOG_SH;
            else
                echo "$item_number) $name ($organization): $comment - $host" >> $TEMP_FILE;
        fi;

        item_number=`expr $item_number + 1`;
    done


} # menu_items

