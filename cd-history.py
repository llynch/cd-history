#!/usr/bin/python

import io
import re
import sys

# print member of a given object
def printm(obj):
    for memeber in dir(obj):
        print memeber

# TODO get env (probably in os)
cdhistory="/home/lynch/.cd_history"

def readLines():
    f = io.open(cdhistory)
    lines = f.readlines()
    f.close()
    # sort lines and remove duplicates
    lines.sort()
    prevline = ""
    uniqlines = []
    for line in lines:
        if line != prevline:
            uniqlines.append(line)
            prevline = line

    # TODO we should save it back to the file
    return uniqlines

def matchLines(lines, patterns):
    matchinglines = []
    for line in lines:
        if matchLine(line, patterns):
            matchinglines.append(line.replace('\n', ''))
    return matchinglines

def matchLine(line, patterns):
    for pattern in patterns:
        if not re.compile(pattern, re.IGNORECASE).search(line):
            return False
    return True

#
# MAIN
#

# find lines that matches
lines = readLines()
patterns = sys.argv[1:]
matchinglines = matchLines(lines, patterns)

if len(matchinglines) == 1:
    # only one result
    sys.exit(matchinglines[0])
elif len(matchinglines) == 0:
    # no results
    sys.exit("")
else:
    # present results to the user
    i = 1
    for line in matchinglines:
        print i.__str__() + " " + line
        i = i+1

    # TODO fix error if user type enter or a non-number
    print "choose a directory:"
    a= input()
    if a != "\n":
        sys.exit(matchinglines[a - 1])

# TODO the pyhont program must return a value
