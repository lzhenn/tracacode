#! /usr/bin/env python
#
# python script to download selected files from rda.ucar.edu
# after you save the file, don't forget to make it executable
#   i.e. - "chmod 755 <name_of_script>"
#
import sys
import os
import urllib2
import cookielib
import datetime
#
   
if (len(sys.argv) != 2):
    print "usage: "+sys.argv[0]+" [-q] password_on_RDA_webserver"
    print "-q suppresses the progress message for each file that is downloaded"
    sys.exit(1)
#
passwd_idx=1
verbose=True
if (len(sys.argv) == 3 and sys.argv[1] == "-q"):
    passwd_idx=2
    verbose=False
#
cj=cookielib.MozillaCookieJar()
opener=urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
#
# check for existing cookies file and authenticate if necessary
do_authentication=False
if (os.path.isfile("auth.rda.ucar.edu")):
    cj.load("auth.rda.ucar.edu",False,True)
    for cookie in cj:
        if (cookie.name == "sess" and cookie.is_expired()):
            do_authentication=True
else:
    do_authentication=True
if (do_authentication):
    login=opener.open("https://rda.ucar.edu/cgi-bin/login","email=lzhenn@mail2.sysu.edu.cn&password="+sys.argv[1]+"&action=login")
#
# save the authentication cookies for future downloads
# NOTE! - cookies are saved for future sessions because overly-frequent authentication to our server can cause your data access to be blocked
    cj.clear_session_cookies()
    cj.save("auth.rda.ucar.edu",True,True)
#
# download the data file(s)

onset_date=[125,136,133,134,143,108,136,123,119,119,128,105,110,132,134,114,126,112,133,132,93,100,115,114,127,118,123,107,116,112,99,134,113,119,123]


for year in range(1979,1979+len(onset_date)-1,1):
    
    start_date = datetime.datetime(year, 1, 1, 0)
    start_date += datetime.timedelta(days=(onset_date[year-1979]-15))
    end_date = start_date+datetime.timedelta(days=25)
    curr_date = start_date
    listoffiles=[]
    while curr_date <= end_date:
        listoffiles.append("ei.oper.an.pl/%04d%02d/ei.oper.an.pl.regn128uv.%04d%02d%02d%02d" % (curr_date.year, curr_date.month, curr_date.year, curr_date.month, curr_date.day, curr_date.hour))
        curr_date += datetime.timedelta(hours=12)


    print listoffiles[0]
    for file in listoffiles:
        idx=file.rfind("/")
        if (idx > 0):
            ofile=file[idx+1:]
        else:
            ofile=file
        if (verbose):
            sys.stdout.write("downloading "+ofile+"...")
            sys.stdout.flush()
        infile=opener.open("http://rda.ucar.edu/data/ds627.0/"+file)
        outfile=open(ofile,"wb")
        outfile.write(infile.read())
        outfile.close()
        if (verbose):
            sys.stdout.write("done.\n")
