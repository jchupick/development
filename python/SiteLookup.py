import sys                          # To get the argument count
import logging                      # Standard Python logging framework with different log levels, etc.
import re                           # Regular expression functionality
import subprocess                   # To be able to issue command line commands
import argparse                     # Python command line argument parser
from operator import xor

###############################################################################################
# Setup command line argument parsing
###############################################################################################
parser = argparse.ArgumentParser()
parser.add_argument('--filename', required=False, help='File containing list of Web servers', metavar='<filename>')
parser.add_argument('--servername', required=False, help='Comma separated list of Web servers (use this OR --filename, but not both)', metavar='<servername>')
parser.add_argument('--all', action="store_true", required=False, default=False, help='If defined, show DNS result for the entry beginning with the server name (which usually does NOT define a website). Default is OFF (tries to show only \"real\" websites')
parser.add_argument('--loglevel', default='WARNING', choices=['CRITICAL','ERROR','WARNING','INFO','DEBUG'], help='Logging level (CRITICAL is lowest level of logging, DEBUG is highest)')
args = parser.parse_args()

if (not xor(bool(args.filename), bool(args.servername))):
    print()
    print("Either --filename OR --servername arguments are required (but not both)")
    print()
    parser.print_help()
    exit()

###############################################################################################

###############################################################################################
# Setup and configure logging object
###############################################################################################
logging_numeric_level = getattr(logging, args.loglevel.upper(), None)
if not isinstance(logging_numeric_level, int):
    parser.print_help()
    exit()

logformatter     = logging.Formatter('%(message)s')
logstreamhandler = logging.StreamHandler()
consoleLog       = logging.getLogger('consoleLog')
logstreamhandler.setFormatter(logformatter)
consoleLog.setLevel(logging_numeric_level)
consoleLog.addHandler(logstreamhandler)
###############################################################################################

# Get the server list, either from --filename or --servername
# (Argumewnt processing earlier ensures that only 1 of the 
# below code blocks will run)
server_names = []
if (bool(args.filename)):
    serverfile = args.filename
    with open(serverfile) as f:
        server_names = f.read().splitlines()
if (bool(args.servername)):
    server_names = args.servername.split(",")
    
for servername in server_names:
    # Poor man's check for comments. If line doesn't 
    # start with a letter, consider it commented.
    servercheckmatch = re.search(r'^[A-z]', servername)
    if not servercheckmatch:
        continue
    print(servername)
    print()
    
    cmdargs = ['powershell', 'Invoke-Command', '-ScriptBlock', '{ ipconfig }', '-ComputerName', '"' + servername + '"']
    consoleLog.debug(' '.join(cmdargs))
    ipconfig_out = subprocess.run(args = cmdargs, 
                                  universal_newlines = True, 
                                  stdout = subprocess.PIPE, 
                                  stderr = subprocess.PIPE
                                  )
    
    pslist_lines = ipconfig_out.stdout.splitlines()

    for pslistline in pslist_lines:
        ismatch = re.search(r'IPv4 Address(.*?)(\d\d?\d?[.]\d\d?\d?[.]\d\d?\d?[.]\d\d?\d?)', pslistline)
        if ismatch:
            currentIP = ismatch.group(2)

            cmdargs = ['nslookup', currentIP]
            consoleLog.debug(' '.join(cmdargs))
            nslookup_out = subprocess.run(args = cmdargs, 
                                          universal_newlines = True, 
                                          stdout = subprocess.PIPE, 
                                          stderr = subprocess.PIPE
                                          )
            
            nslookup_lines = nslookup_out.stdout.splitlines()

            name = ""
            for nslookupline in nslookup_lines:
                nslmatch = re.search(r'Name:(.*)', nslookupline)
                if nslmatch:
                    name = nslmatch.group(1)
                    issamepattern = r'{}[.]'.format(servername)
                    issameservermatch = re.search(issamepattern, name)
                    if ((not issameservermatch) or (issameservermatch and args.all)):
                        print('{:52s} {:16s}'.format(name, currentIP))
    print()        
