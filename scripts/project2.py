# -*- coding: utf-8 -*-
"""
Created on Sat Jun 10 19:26:13 2017

@author: jmf
"""

import os
import re
import pandas as pd
import time

MIDpatt = re.compile("<(.+?)>")
FROMpatt = re.compile("From: (.+?@.+?)\n")
TOpatt = re.compile("To: ((.+?@.+?,[ \n]*)*[ ]*(.+?@.+?)\n)")
DATEpatt = re.compile("Date: (.+?)\n")

def getFirstMessage(msg):
    # messages start with two newlines
    startInd = msg.find('\n\n')
    msg = msg[startInd:]
    
    # look for one of the signs of an email chain
    forwarded = msg.find("----- Forwarded by")
    orig = msg.find("-----Original Message")
    
    if forwarded == -1 and orig == -1:
        return msg
    else:
        inds = [i for i in (forwarded,orig) if i > -1]
        ind = min(inds)
        return msg[:ind]
    

path = "../maildir/"
messageIDs = set()
allTextFiles = [os.path.join(root,fname) for root,dirs,files in os.walk(path) for fname in files]

entities = set()
received = {}
sent = {}
print(len(allTextFiles))
t1 = time.time()
for fnum, fname in enumerate(allTextFiles):
    if fnum % 1000 == 0:
        print(fnum)
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
            txt = getFirstMessage(text)
            txt = txt.replace("--",'')
            
            ignore = (fromVal.find("administrator") > -1)
            ignore = ignore or (fromVal.find("mbx_") > -1)
            ignore = ignore or (fromVal.find("pete.davis") > -1)
            if fromVal.find("@enron.com") > -1 and len(txt) > 20 and len(txt)<5000 and not ignore:
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
                            sent[fromVal] = set()
                        if date not in received[fromVal][toVal]:
                            received[fromVal][toVal].add(date)
                            sent[fromVal].add(txt)
#                        print(txt)
#                        stop=raw_input("")
    #                print(toVals)
print(time.time()-t1)
edgeList = []
name2ind = {k:i for i,k in enumerate(list(entities))}
biggestEmailers = sorted(sent.iteritems(),key=lambda x: len(x[1]), reverse=True)[:100]
emailsOut = []
for name, emails in biggestEmailers:
    for email in emails:
        emailsOut.append([name,email])
emailDF = pd.DataFrame(emailsOut, columns=["add","txt"])
print(emailDF.head())
emailDF.to_csv("../allTopEmailers.csv", index=False)
#for sender,receivers in received.iteritems():
#    for receiver,count in receivers.iteritems():
#        origin = name2ind[sender]
#        terminus = name2ind[receiver]
#        weight = len(count)
#        edgeList.append( [origin, terminus, weight])
#df = pd.DataFrame(edgeList,columns=["From","To","Weight"])
#df.to_csv("../edgeList.csv",index=False)
#df2 = pd.DataFrame(sorted(name2ind.iteritems(),key=lambda x: x[1]),columns=["Name","Index"])
#df2.to_csv("../NamesToIndices.csv",index=False)