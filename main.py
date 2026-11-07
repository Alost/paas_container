import os
import sys

SCRIPT = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'start.sh')
args = [SCRIPT] if os.path.exists(SCRIPT) else ['-i']
os.execv('/usr/bin/env', ['env', 'bash', *args, *sys.argv[1:]])
