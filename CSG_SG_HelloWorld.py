#
# * ReaScript Name: CSG_SG_HelloWorld
# * Description: 
# * Instructions: 
# * Author: Simon Gumbleton
# * Version: 1.0
#


import sys
from reaper_python import * 

def msg(msg):
    RPR_ShowConsoleMsg(msg)
    return

msg('Version ' + sys.version + '\n\n')
msg('Current module search path entries:' + '\n\n')
for i in range(1, len(sys.path)):
    msg('  ' + sys.path[i] + '\n')
msg('\n')