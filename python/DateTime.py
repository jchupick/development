import calendar
from datetime import time
from datetime import date
from datetime import datetime

now = datetime.now()

c       = calendar.TextCalendar(calendar.SUNDAY)
mcalstr = c.formatmonth(now.year, now.month)
print(mcalstr)
 
ycalstr = c.formatyear(now.year)
print(ycalstr)

for i,day in enumerate(c.itermonthdays(now.year, now.month)):
    pass
#    print(i, day)

for i,day in enumerate(c.itermonthdays2(now.year, now.month)):
    pass
#    print(i, day)

for i,day in enumerate(c.itermonthdates(now.year, now.month)):
    pass
#    print(i, day)
