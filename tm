#!/usr/bin/python

# begin config
localTimeZone="US/Mountain"
remoteTimeZone="Europe/London"

salesOpenTime="4:00"
#salesCloseTime="5.30pm"
#salesClosedDaysOfWeek=[5,6] # 0=monday 6 = sunday
salesCloseTime="23:30"
salesClosedDaysOfWeek=[5,6] # 0=monday 6 = sunday

billingOpenTime="9:00"
billingCloseTime="17:00"
billingClosedDaysOfWeek=[5,6]
# end config

import time
import datetime
import os

class bcolors:
    purple = '\033[95m'
    blue = '\033[94m'
    green = '\033[92m'
    yellow = '\033[93m'
    red = '\033[91m'
    white = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def setTimeZone(timezone):
    os.environ['TZ']=timezone
    time.tzset()


class availability:
    def __init__(self, oTime,cTime,closedDaysOfWeek):
        setTimeZone(remoteTimeZone)
        today = datetime.date.today().strftime("%Y/%m/%d/")
        self.oTime = datetime.datetime.strptime(today+oTime,"%Y/%m/%d/%H:%M")  # parsing the time given

        self.cTime = datetime.datetime.strptime(today+cTime,"%Y/%m/%d/%H:%M")  # parsing the time given
        self.closedDaysOfWeek = closedDaysOfWeek
    oTime = ""
    cTime = ""
    closedDaysOfWeek = []
    def isOpenOnDay(self,day):
        setTimeZone(remoteTimeZone)
        for closedDay in self.closedDaysOfWeek:
            if day.weekday() == closedDay:
                return False
        return True
    def isOpenToday(self):
        setTimeZone(remoteTimeZone)
        return self.isOpenOnDay(datetime.date.today())
    def isOpenNow(self):
        setTimeZone(remoteTimeZone)
        now = datetime.datetime.now()
        return self.isOpenToday() and now >= self.oTime and now <= self.cTime
    def openTimeLeft(self):
        if self.isOpenNow():
            return self.cTime - datetime.datetime.now()
        else:
            return 0
    def getNextOpenDateTime(self):
        oneDay = datetime.timedelta(1)
        day = self.oTime + oneDay
        while len(self.closedDaysOfWeek) > 0 and not self.isOpenOnDay(day):
            day += oneDay
        return day
    def closedTimeLeft(self):
        now = datetime.datetime.now()
        if not self.isOpenNow() and self.isOpenToday and now < self.oTime:
            return self.oTime - now
        elif not self.isOpenNow():
            return self.getNextOpenDateTime() - now
        return 0




def printTime():
    #print (time.strftime("%x    %I:%M:%S%p %Y  "+bcolors.purple+"-%Z"+bcolors.white))
    print (time.strftime("%x    %H:%M:%S %Y  "+bcolors.purple+"-%Z"+bcolors.white))
def getTimeDiff():
    setTimeZone(localTimeZone)
    here=datetime.datetime.now()
    setTimeZone(remoteTimeZone)
    there=datetime.datetime.now()
    return there-here

salesA = availability(salesOpenTime,salesCloseTime,salesClosedDaysOfWeek)
billingA = availability(salesOpenTime,salesCloseTime,salesClosedDaysOfWeek)
test = availability("8:00","6:00",[])


setTimeZone(localTimeZone)
here=datetime.datetime.now()
printTime()
setTimeZone(remoteTimeZone)
there=datetime.datetime.now()
printTime()

print ('sales open today: ' + str(salesA.isOpenToday()))
print ('billing open today: ' + str(billingA.isOpenToday()))
print ('sales is ' + str(salesA.isOpenNow()))
print ('billing is ' + str(billingA.isOpenNow()))

print("timeDiff: " + str(getTimeDiff()))


print("Sales \t\topens: %s closes: %s"%(salesOpenTime,salesCloseTime) )
print("Billing \topens: %s closes: %s"%(billingOpenTime,billingCloseTime) )
