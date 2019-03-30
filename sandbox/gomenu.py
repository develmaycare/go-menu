#! /usr/bin/env python

import re
import sys

sys.path.insert(0, "../")

from gomenu.cli import main_command

if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
    sys.exit(main_command())
