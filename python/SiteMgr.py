import sys                          # To get the argument count
import logging                      # Standard Python logging framework with different log levels, etc.
import re                           # Regular expression functionality
import subprocess                   # To be able to issue command line commands
import json                         # To convert a Python dictionary object to a JSON stream
import argparse                     # Python command line argument parser
import xml.etree.ElementTree        # For parsing XML files

###############################################################################################
# Setup command line argument parsing
###############################################################################################
parser = argparse.ArgumentParser()
parser.add_argument('--filename', required=True, help='File containing list of Web servers', metavar='<filename>')
parser.add_argument('--loglevel', default='WARNING', choices=['CRITICAL','ERROR','WARNING','INFO','DEBUG'], help='Logging level (CRITICAL is lowest level of logging, DEBUG is highest)')
if (len(sys.argv) <= 1):
    parser.print_help()
    exit()
args = parser.parse_args()
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

def getAppnameFromWebConfig(webconfigfilenameparam):
    returnappbinary = ''        # Always return a string, even if not found.
    try:
        tree = xml.etree.ElementTree.parse(webconfigfilenameparam)
        root = tree.getroot()
        aspnetroot = root.find("./system.webServer/aspNetCore")
        returnappbinary = aspnetroot.get('processPath')
        returnappbinary = re.sub(r'^[.][\\](.+)', r'\1', returnappbinary)   # Get rid of leading '.\' if it's there
    except Exception as ex:
        exmessage = 'Exception::{}'.format(type(ex).__name__)
        consoleLog.debug("{} ===> {}".format(exmessage, webconfigfilenameparam))

    return returnappbinary

with open(args.filename) as f:
    file_lines = f.read().splitlines()

masterdictionary   = {}
siteserverkeydelim = '::'       # Global, unique dictionary key will look like:    sevrername::sitename
    
for servername in file_lines:
    # Poor man's check for comments. If line doesn't 
    # start with a letter, consider it commented.
    servercheckmatch = re.search(r'^[A-z]', servername)
    if not servercheckmatch:
        continue
    consoleLog.info('Server: ' + servername)
    
    ###############################################################################################
    #
    # Run the command:  appcmd list site
    #
    ###############################################################################################
    cmdargs = ['psexec', '\\\\' + servername, 'appcmd', 'list', 'site']
    consoleLog.debug(' '.join(cmdargs))
    appcmdcmd = subprocess.run(args = cmdargs, 
                                  universal_newlines = True, 
                                  stdout = subprocess.PIPE, 
                                  stderr = subprocess.PIPE
                                  )
    
    appcmd_lines = appcmdcmd.stdout.splitlines()

    for line in appcmd_lines:
        linematch = re.search(r'SITE "(.+)" [(](.+)[)]', line)
        if linematch:
            sitename = linematch.group(1)
            
            detailsmatch = re.search(r'id:(.+?),bindings:(.+?),state:(.+?)$', linematch.group(2))
            
            if detailsmatch:
                siteid       = detailsmatch.group(1)
                sitebindings = detailsmatch.group(2)
                sitestate    = detailsmatch.group(3)
            
            singlesite = {}

            bindingslist = sitebindings.split(",")
            for binding in bindingslist:
                bindingnvlist = binding.split("/")
                singlesite['binding-' + bindingnvlist[0]] = bindingnvlist[1]

            singlesite['name']           = sitename
            singlesite['id']             = siteid
            singlesite['bindingsdetail'] = sitebindings
            
            singlesite['state']     = sitestate
            singlesite['server']    = servername
            
            siteserverkey = sitename + siteserverkeydelim + servername
            masterdictionary[siteserverkey] = singlesite
            
    ###############################################################################################
    #
    # Run the command:  appcmd list app
    #
    #   This will find the apppool and add it to the dictionary for the already located site
    #
    ###############################################################################################
    cmdargs = ['psexec', '\\\\' + servername, 'appcmd', 'list', 'app']
    consoleLog.debug(' '.join(cmdargs))
    appcmdcmd = subprocess.run(args = cmdargs, 
                              universal_newlines = True, 
                              stdout = subprocess.PIPE, 
                              stderr = subprocess.PIPE
                              )
    
    appcmd_lines = appcmdcmd.stdout.splitlines()

    for line in appcmd_lines:
        linematch = re.search(r'APP "(.+)/" [(]applicationPool:(.+)[)]', line)
        if linematch:
            pass
            sitename    = linematch.group(1)
            apppoolname = linematch.group(2)
            # Find the dictionary for this sitename in the master 
            # and add the name-value pair for apppool
            try:
                siteserverkey = sitename + siteserverkeydelim + servername
                tempdict = masterdictionary[siteserverkey]
                tempdict['apppool'] = apppoolname
            except KeyError as ex:
                exmessage = 'Exception during appcmd app::{}'.format(type(ex).__name__)
                consoleLog.warning("Key: {} does NOT exist. {}".format(siteserverkey, exmessage))
            

    ###############################################################################################
    #
    # Run the command:  appcmd list apppool
    #
    #   This will find apppool details and add them to the dictionary for the already located site
    #
    ###############################################################################################
    cmdargs = ['psexec', '\\\\' + servername, 'appcmd', 'list', 'apppool']
    consoleLog.debug(' '.join(cmdargs))
    appcmdcmd = subprocess.run(args = cmdargs, 
                              universal_newlines = True, 
                              stdout = subprocess.PIPE, 
                              stderr = subprocess.PIPE
                              )
    
    appcmd_lines = appcmdcmd.stdout.splitlines()

    for line in appcmd_lines:
        linematch = re.search(r'APPPOOL "(.+)" [(](.+)[)]', line)
        if linematch:
            pass
            loopapppoolname = linematch.group(1)
            apppooldetails  = linematch.group(2)
            # Expecting a string with a comma separated list of 
            # name-value pairs that are ":" separated 
            apppoolsplit = apppooldetails.split(",")
            for apppooltokens in apppoolsplit:
                apppooltokensplit = apppooltokens.split(":")
                if   (apppooltokensplit[0] == 'MgdVersion'):
                    mgdversion = apppooltokensplit[1]
                elif (apppooltokensplit[0] == 'MgdMode'):
                    mgdmode = apppooltokensplit[1]
                elif (apppooltokensplit[0] == 'state'):
                    apppoolstate = apppooltokensplit[1]
                            
            # For now, need to loop through the entire master list, looking 
            # for any site that uses this apppool, and add those details to 
            # that sites dictionary
            for key in masterdictionary.keys():
                tempdict = masterdictionary[key]
                if (tempdict['apppool'] == loopapppoolname):
                    # tempdict['apppooldetails']    = apppooldetails
                    tempdict['apppoolmgdversion'] = mgdversion
                    tempdict['apppoolmgdmode']    = mgdmode
                    tempdict['apppoolstate']      = apppoolstate

    ###############################################################################################
    #
    # Run the command:  appcmd list vdir
    #
    #   This will find the directory and add it to the dictionary for the already located site
    #
    ###############################################################################################
    cmdargs = ['psexec', '\\\\' + servername, 'appcmd', 'list', 'vdir']
    consoleLog.debug(' '.join(cmdargs))
    appcmdcmd = subprocess.run(args = cmdargs, 
                              universal_newlines = True, 
                              stdout = subprocess.PIPE, 
                              stderr = subprocess.PIPE
                              )
    
    appcmd_lines = appcmdcmd.stdout.splitlines()

    for line in appcmd_lines:
        linematch = re.search(r'VDIR "(.+)/" [(]physicalPath:(.+?)[)]', line)
        if linematch:
            pass
            sitename    = linematch.group(1)
            directory   = linematch.group(2)
            # Find the dictionary for this sitename in the master 
            # and add the name-value pair for apppool
            try:
                siteserverkey = sitename + siteserverkeydelim + servername
                tempdict = masterdictionary[siteserverkey]
                tempdict['directory'] = directory
                # build a unc friendly directory and store
                uncdirectory = '\\\\' + servername + '\\' + re.sub(r'^([c-zC-Z]):', r'\1$', directory)
                tempdict['uncdirectory'] = uncdirectory
                # Pull the application exe or dll from web.config, then 
                # find the defined exe or dll within web.config
                webconfigfilename  = uncdirectory + '\\web.config'
                tempdict['appbinary'] = getAppnameFromWebConfig(webconfigfilename)
            except KeyError as ex:
                exmessage = 'Exception during appcmd vdir::{}'.format(type(ex).__name__)
                consoleLog.warning("Key: {} does NOT exist. {}".format(siteserverkey, exmessage))
            
for key in masterdictionary.keys():
    print('{:18} {:52}'.format('Site Key:', key))
    print('-----------------------------------------------------------')
    tempdict = masterdictionary[key]
    for key1 in tempdict.keys():
        print('{:18} {:52}'.format(key1, tempdict[key1]))
    print()

masterjsonstring = json.dumps(masterdictionary, indent = 4)
consoleLog.debug(masterjsonstring)
