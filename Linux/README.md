## Systemd and Services

1. you load the daemon script on the server (python, for exampleO)
2. you create a systemd service file in   /etc/systemd/system/
   filename may contain an @ sign (which is the mechanism for referring to service instances)
        
    Foo.service 
    Foo@.service

    This file contains a description, env variables, and startup command (ExecStart)
3.  When you start or enable it,  the SERVICE file (not the daemon script) is 
        cached by Systemd (you will need to know this later if you change the SERVICE file.
        You only need to clear the Systemd cache if you change the SERVICE, not the script).
4.  Start/Stop       means run / kill the daemon script now
5.  Enable/Disable   means put it into / take it out of the config to start at reboot
        Enable has one purpose:  To add it to the list of services to start at reboot.
            In order for Systemd to enable it, the service file must be cached so Systemd will do
            that but that is not the primary purpose of enable.  Starting the service will likewise
            cache the service file out of necessity, not as a primary or exclusive function.
        Show list of all enabled services:
            systemctl list-unit-files | grep enabled
        Show list of all all services running
            systemctl | grep running
        Check a specific service:
            systemctl status Foo            (when there is no @)
            systemctl status Foo@{1..3}     (must provided desired instance numbers if there is an @ sign)
            or:  ps aux | grep FOO
6.  When there is an @ sign in the service name,  you can   start/stop/enable/disable   mutiple instances at once.
        This is merely a labor saving device for the command line.  It does not cache the service file differently
            and it does not declare or configure the service to have some preset number of instances.
        Instance variable usage:
        
            systemctl [start|stop|enable|disable] alarm_callback_send_curl@1           Just instance 1
            systemctl [start|stop|enable|disable] alarm_callback_send_curl@{1,3}       Just instances 1 and 3
            systemctl [start|stop|enable|disable] alarm_callback_send_curl@{1..3}      All instances from 1 - 3
        In the body of the text of the service file, Systemd provides %i as the instance variable.  This can be used
            in the description and (presumably) as an argument in the startup command:
                Description=Foo is a service that adds widgets and gadgets, instance %i
                ExecStart=/var/rabbitmq/app/env/bin/python3 alarm_callback_send_curl.py foo %i bar
        
7.  If you edit or remove a service (not the daemon script),  you will need to flush Systemd's cached service files: 
    systemctl daemon-reload
    systemctl reset-failed
