#!/usr/bin/python

# begin config
localTimeZone="US/Mountain"
remoteTimeZone="Europe/London"

salesOpenTime="9:00"
salesCloseTime="17:30"
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
        setTimeZone(remoteTimeZone)
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
        setTimeZone(remoteTimeZone)
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
billingA = availability(billingOpenTime,billingCloseTime,billingClosedDaysOfWeek)

import argparse
from sys import argv

parser = argparse.ArgumentParser(description='A uk2 time tool.')

parser.add_argument('time', help="Convert given time in the format XX:XX/XX:XXam from local time to remote time.", nargs='?')

parser.add_argument('-H','--hours', help="display the hours for sales and billing in  %s time"%remoteTimeZone, action='store_true')
parser.add_argument('-r','--remote', help="display the %s time"%remoteTimeZone, action='store_true')
parser.add_argument('-l','--local', help="display the %s time"%localTimeZone, action='store_true')
parser.add_argument('-s','--sales', help="Display if sales is open/closed and how long till close/open.", action='store_true')
parser.add_argument('-b','--billing', help="Display if billing is open/closed and how long till close/open.", action='store_true')
parser.add_argument('-a','--all', help="Display all options", action='store_true')
args = parser.parse_args()

import re # regex
army = re.compile('^((00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23)[:]?[0-5]\d)$')
reg = re.compile('^(([0-1])?\d[:][0-5]\d(am|pm))$')

setTimeZone(remoteTimeZone)
if args.time and reg.match(args.time):
    newTime = datetime.datetime.strptime(args.time,"%I:%M%p")-getTimeDiff()
    print(newTime.strftime("%I:%M%p")+" "+remoteTimeZone)
elif args.time and army.match(args.time):
    newTime = datetime.datetime.strptime(args.time,"%H:%M")-getTimeDiff()
    print(newTime.strftime("%H:%M")+" "+remoteTimeZone)
elif args.time:
    print (' !bad Time formating >'+args.time  )
if args.all:
    args.local = True
    args.remote = True
    args.sales = True
    args.billing = True
    
if args.local:
    setTimeZone(localTimeZone)
    printTime()
    setTimeZone(remoteTimeZone)
if args.remote:
    setTimeZone(remoteTimeZone)
    printTime()

if args.billing:
    setTimeZone(remoteTimeZone)
    if billingA.isOpenNow():
        print ("Billing is "+bcolors.green+"OPEN"+bcolors.white+" for %s."%str(billingA.openTimeLeft()).split('.', 2)[0])
    else:
        print ("Billing is "+bcolors.red+"CLOSED"+bcolors.white+" for %s."%str(billingA.closedTimeLeft()).split('.', 2)[0])
if args.sales:
    setTimeZone(remoteTimeZone)
    if salesA.isOpenNow():
        print ("Sales is "+bcolors.green+"OPEN"+bcolors.white+" for %s."%str(salesA.openTimeLeft()).split('.', 2)[0])
    else:
        print ("Sales is "+bcolors.red+"CLOSED"+bcolors.white+" for %s."%str(salesA.closedTimeLeft()).split('.', 2)[0])
if args.hours:
    print("Sales \t\topens: %s closes: %s"%(salesOpenTime,salesCloseTime) )
    print("Billing \topens: %s closes: %s"%(billingOpenTime,billingCloseTime) )

# if no arguments
if len(argv) <= 1:
    setTimeZone(remoteTimeZone)
    printTime()
