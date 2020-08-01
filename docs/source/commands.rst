.. _commands:

********
Commands
********

The ``go`` command is used to start a new session on a remote server.

.. code-block:: text

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

    - ~/username/.gomenu/resources.csv
    - /etc/gomenu/resources.csv
    - /opt/gomenu/resources.csv

    These files are read in the order above. The valid columns are:

    name - The name of the resource. Required. Cannot contain a space.

    organization - A short code or abbreviation representing the organization that
    owns the resource. Required. Limited to 3 or 4 characters.

    comment - A brief comment or description of the resource. Required. Limited to
    about 30 characters.

    host - The actual host name that is the target of the connection. Required.

    port - TCP port. Required, but defaults to 22.

    user - The user name for the connection. Optional. Defaults to shawn.

    protocol - Not implemented. Defaults to ssh. This is a placeholder for possibly
    implementing other protocols in the future.

    key_file - The SSH key file to use, if any. If given, your public key needs to
    be in the authorized_keys of the user account on the host machine.
