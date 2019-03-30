# Imports

from configparser import ConfigParser
from deployable.hosts import factory as host_factory
from dialog import Dialog
from myninjas.utils import write_file
from subprocess import getstatusoutput
import sys

# Exports

# Classes


class Menu(object):

    def __init__(self, path, title="Select a Host"):
        self.command = None
        self.hosts = host_factory(path)
        self.title = title

    def run(self):
        choices = list()
        for host in self.hosts:
            choices.append((host.name, ", ".join(host.roles)))

        d = Dialog()

        code, choice = d.menu(self.title, choices=choices)

        if code == d.OK:
            for host in self.hosts:
                if choice == host.name:
                    self.command = host.get_command()

                    break

            return 0
        elif code == d.ESC:
            print(code, choice)
            return 1
        else:
            print(code, choice)
            return 2
