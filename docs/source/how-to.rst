.. _how-to:

******
How To
******

Set the Path to Resources
=========================

You may set the path to the ``resources.csv`` file in the ``~/.gomenu/preferences.cfg`` file.

.. tip::
    The ``preferences.cfg`` is created the first time ``go`` is executed. You may also manually create this file.

Use An Alternative Resources File
=================================

You may manually specify a resources file using the ``-f`` switch:

.. code-block:: bash

    go -f /path/to/alternative-resources.csv;

Control the Dimensions of Dialogs
=================================

It is possible to control the dimensions of dialog menus. The default usually works, but if you have particularly large or small screen, you may wish to customize.

Edit your ``~/.gomenu/preferences.cfg`` file and add the following lines, adjusting as needed:

.. code-block:: bash

    dialog_height=25;
    dialog_width=79;
    dialog_menu_height=20;

Create an Announcement
======================

You may create an announcement by writing to a user's ``~/.gomenu/news.txt`` file.

The contents of the file will be displayed to the user the next time ``go`` is executed, and then removed.
