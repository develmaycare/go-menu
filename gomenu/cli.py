# Imports

from argparse import ArgumentParser, RawDescriptionHelpFormatter
import os
import pty
import sys
from .library import Menu

# import logging
# from myninjas.shell import EXIT_SUCCESS, EXIT_UNKNOWN
# from myninjas.logging import LoggingHelper
# import os
# import sys
# from .subcommands import badge_command, dumpdata_command, info_command, init_command, loaddata_command, ls_command, \
#     password_command, requirements_command, version_command
# from ..constants import LOGGER_NAME as DEFAULT_LOGGER_NAME
# from .initialize import SubCommands
#
# LOGGER_NAME = os.environ.get("PYTHON_PROJECTUTILS_LOGGER_NAME", DEFAULT_LOGGER_NAME)
#
# log = LoggingHelper(colorize=True, name=LOGGER_NAME)
# logger = log.setup()

DEFAULT_PATH = "./example.ini"

# Commands


def main_command():
    """Connect to your servers via SSH."""

    __author__ = "Shawn Davis <shawn@develmaycare.com>"
    __date__ = "2018-11-05"
    __help__ = """NOTES

TODO

    """
    __version__ = "4.0.0-d"

    parser = ArgumentParser(description=__doc__, epilog=__help__, formatter_class=RawDescriptionHelpFormatter)

    parser.add_argument(
        "-P=",
        "--path=",
        default=DEFAULT_PATH,
        dest="path",
        help="Path to the hosts.ini file. Default: %s" % DEFAULT_PATH
    )

    # # Initialize sub-commands.
    # subparsers = parser.add_subparsers(
    #     dest="subcommand",
    #     help="Commands",
    #     metavar="badge, dumpdata, info, init, loaddata, ls, password, requirements, version"
    # )
    #
    # commands = SubCommands(subparsers)
    # commands.badge()
    # commands.dumpdata()
    # commands.info()
    # commands.init()
    # commands.loaddata()
    # commands.ls()
    # commands.password()
    # commands.requirements()
    # commands.version()

    # Access to the version number requires special consideration, especially
    # when using sub parsers. The Python 3.3 behavior is different. See this
    # answer: http://stackoverflow.com/questions/8521612/argparse-optional-subparser-for-version
    parser.add_argument(
        "-v",
        action="version",
        help="Show version number and exit.",
        version=__version__
    )

    parser.add_argument(
        "--version",
        action="version",
        help="Show verbose version information and exit.",
        version="%(prog)s" + " %s %s by %s" % (__version__, __date__, __author__)
    )

    # Parse the given arguments.
    args = parser.parse_args()
    print(args)

    menu = Menu(args.path)

    def read(fd):
        data = os.read(fd, 1024)
        # script.write(data)
        return data

    exit_code = 0
    while exit_code == 0:
        exit_code = menu.run()
        if menu.command is not None:
            pty.spawn(menu.command, read)

    # Quit.
    sys.exit()
