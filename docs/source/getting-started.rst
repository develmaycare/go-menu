.. _getting-started:

***************
Getting Started
***************

System Requirements
===================

The Go Menu currently requires a shell that the dialog, and of course that dialog is installed.

.. tip::
    If you are on a Mac and using Homebrew, you may install dialog with the ``brew install dialog`` command.

.. note::
    The Go Menu *will* function using a simple text-driven menu if dialog is not installed.

Install
=======

Get the source code:``git clone https://github.com/develmaycare/go-menu``

For the default installation, simply run ``make install`` from the gomenu directory. By default, the ``go`` command is installed in ``/usr/local/bin``. But you can change this by specify a prefix like so:

.. code-block:: bash

    make install PREFIX=/path/to/my/preferred/bin

Configuration
=============

By default, the go command reads resources from a CSV file located in one of the following locations:

- ``$HOME/.gomenu/resources.csv``
- ``/etc/gomenu/resources.csv``
- ``/opt/gomenu/resources.csv``

.. tip::
    You may override the resources location. See :ref:`how-to`.

These files are read in the order above. The columns of the CSV are as follows:

``# <Name>, <Organization>, <Comment>, <Host>, [Port], [User], [Protocol], [Key File]``

- ``name`` - The name of the resource. Required. Cannot contain a space.
- ``organization`` - A short code or abbreviation representing the organization that owns the resource. Required. Limited to 3 or 4 characters.
- ``comment`` - A brief comment or description of the resource. Required. Limited to about 30 characters.
- ``host`` - The actual host name that is the target of the connection. Required.
- ``port`` - TCP port. Required, but defaults to 22.
- ``user`` - The user name for the connection. Optional. Defaults to ``whoami``.
- ``protocol``: Not implemented. Defaults to ssh. This is a placeholder for possibly implementing other protocols in the future.
- ``key_file``: The name of the key file to use for the connection.

Here some examples:

.. code-block:: text

    Academic,University of Education,List Server,listserv.uof.edu,,,ssh,uofe.pem
    MsPiggy,ACME Inc.,Windows File Server,mspiggy.example.com,999,admin,ssh,
    RedHat6,ABC Corp,Web Server,redhat6.example.com,4894,deploy,ssh,id_rsa
    Venus,ACME Inc,Web Server,venus.example.com,4894,bob,ssh,bob.pem

Examples
========

Try ``go --help`` to see Go Menu help.

Next Steps
==========

Add some resources to your ``resources.csv`` file. See :ref:`how-to`.
