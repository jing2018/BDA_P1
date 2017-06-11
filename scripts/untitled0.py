# -*- coding: utf-8 -*-
"""
Created on Sat Jun 10 19:26:13 2017

@author: jmf
"""

import os
import re
MIDpatt = re.compile("<(.+?)>")
FROMpatt = re.compile("From: (.+?@.+?)\n")
TOpatt = re.compile("To: ((.+?@.+?,[ \n]*)*[ ]*(.+?@.+?)\n)")
DATEpatt = re.compile("Date: (.+?)\n")

path = "../maildir/"
messageIDs = set()
allTextFiles = [os.path.join(root,fname) for root,dirs,files in os.walk(path) for fname in files]

entities = set()
received = {}

for fname in allTextFiles:
    with open(fname,'r') as f:
        text = f.read()
#        print(text)
        messageID = re.search(MIDpatt,text).groups(0)
        if not messageID in messageIDs:
            messageIDs.add(messageID)
        fromVal = re.search(FROMpatt,text)
        date = re.search(DATEpatt,text)
        if (not (fromVal is None)) and (not (date is None)):
            fromVal = fromVal.groups(0)[0].strip()
            date = date.groups(0)[0]
            if fromVal.find("@enron.com") > -1:
                if not fromVal in entities:
                    entities.add(fromVal)
                if not fromVal in received.keys():
                    received[fromVal] = {}
                toLines = re.search(TOpatt,text)
                if not toLines is None:
                    toLines = toLines.groups(0)[0]
                    toLines = toLines.replace("To: ",'')
                    toVals = [i.strip() for i in toLines.split(',') if i.find("@enron.com") > -1]
                    for toVal in toVals:
                        if not toVal in entities:
                            entities.add(toVal)
                        if not toVal in received[fromVal]:
                            received[fromVal][toVal] = set()
                        received[fromVal][toVal].add(date)
    #                print(toVals)
edgeList = []
name2ind = {k:i for i,k in enumerate(list(entities))}                    
for sender,receivers in received.iteritems():
    for receiver,count in receivers.iteritems():
        origin = name2ind[sender]
        terminus = name2ind[receiver]
        weight = len(count)
        edgeList.append( [origin, terminus, weight])