# Import smtplib for the actual sending function
import smtplib

# Import the email modules we'll need
from email.message import EmailMessage

textfile = 'mailmsg.txt'
mailmsg  = 'Content directly from python string\nSecond line...\nthird'

# Send file contents
#with open(textfile) as fp:
#    msg = EmailMessage()
#    msg.set_content(fp.read())

# Send string iteself
msg = EmailMessage()
msg.set_content(mailmsg)

# me == the sender's email address
# you == the recipient's email address
#msg['Subject'] = 'The contents of %s' % textfile
msg['Subject'] = 'The contents of a string'
msg['From']    = 'jchupick@ansi.org'
msg['To']      = ['jchupick@ansi.org', 'jchupick@gmail.com']

# Send the message via our own SMTP server.
s = smtplib.SMTP('smtprelay.ansi.org')
s.send_message(msg)
s.quit()
