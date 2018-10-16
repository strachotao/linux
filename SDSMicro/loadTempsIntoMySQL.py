#!/usr/bin/python -tt
# -*- coding: utf-8 -*-
"""
loadTempIntoMySQL; version 2016-10-20; strachotao 

Parse SDS Micro's temperatures http://{sds-micro-ip}/temp.xml and save it into MySQL database

table structure:
CREATE TABLE `temp_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `timestamp` varchar(19) CHARACTER SET utf8 NOT NULL,
  `temp_1` decimal(4,2) DEFAULT NULL,
  `temp_2` decimal(4,2) DEFAULT NULL,
  `temp_3` decimal(4,2) DEFAULT NULL,
  `temp_4` decimal(4,2) DEFAULT NULL,
  `warning_counter` int(4) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=binary;
"""

from xml.dom import minidom
from time import strftime
from datetime import datetime
from decimal import Decimal

import urllib2
import MySQLdb

import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText

from config import *


def getCurrentWarningCounter():
    with mysql:
        cursor = mysql.cursor()
        query = "SELECT warning_counter \
                FROM "+str(config['mysqlTable'])+" \
                ORDER BY ID DESC LIMIT 1"
        cursor.execute(query)
        result = cursor.fetchone()
        return result


def getTemperatures():
    try:
        response = urllib2.urlopen(config['XMLSource'])
        xmldoc = minidom.parse(response)
    except:
        print("shit happens while getting data")
        if datetime.now().hour in config['errorEmailHour']:
            if datetime.now().minute == config['errorEmailMinute']:
                sendWarningEmail()
    else:
        temperatures['timestamp'] = str(getTimestamp())
        for id in config['sensors']:
            if config['sensors'][id]['enabled']:
                sensor = 'temp_'+str(id)
                if xmldoc.getElementsByTagName(sensor):
                    tagElement = xmldoc.getElementsByTagName(sensor)
                    temperatures[sensor] = tagElement[0].firstChild.nodeValue
                else:
                    temperatures[sensor] = '0'


def getOriginWarningTimestamp():
    with mysql:
        cursor = mysql.cursor()
        query = "SELECT timestamp \
                FROM "+str(config['mysqlTable'])+" \
                WHERE warning_counter = '0' \
                ORDER BY ID DESC LIMIT 1"
        cursor.execute(query)
        result = cursor.fetchone()
        return result


def sendEmail(sensor, treshold, currentTemperature, desc, timestamp, originTimestamp):
    msg = MIMEMultipart()
    msg['From'] = config['emailFrom']
    msg['To'] = ", ".join(config['emailTo'])
    msg['Subject'] = "WARN:"+str(sensor)+"="+str(currentTemperature)+"C"
    if currentTemperature == 0:
        mess1 = "Varovani, cidlo "+str(sensor)+" ("+str(desc)+") nereaguje.\n\n"
    else:
        mess1 = "Varovani, cidlo "+str(sensor)+" ("+str(desc)+") prekrocilo limit varovani "+str(treshold)+".\n\n"
    mess2 = "Aktualni teplota je "+str(currentTemperature)+"C, varovani vzniklo "+str(originTimestamp)+"\n\n"
    mess3 = str(temperatures)
    message = mess1 + mess2 + mess3
    msg.attach(MIMEText(message))
    mailserver = smtplib.SMTP('localhost')
    mailserver.sendmail(config['emailFrom'], config['emailTo'], msg.as_string())
    mailserver.quit()

def sendWarningEmail():
    msg = MIMEMultipart()
    source = config['XMLSource']
    msg['From'] = config['emailFrom']
    msg['To'] = ", ".join(config['emailTo'])
    msg['Subject'] = "ERR: nedostupna jednotka"
    mess1 = "Varovani, data z  "+str(source)+" nejdou nacist. Jednotka SBS-Micro je nedostupna.\n\n"
    msg.attach(MIMEText(mess1))
    mailserver = smtplib.SMTP('localhost')
    mailserver.sendmail(config['emailFrom'], config['emailTo'], msg.as_string())
    mailserver.quit()

def getTimestamp():
    return(strftime('%Y.%m.%d %H:%M:%S'))


def isWarningStatus():
    thisResult = False
    for key, value in temperatures.iteritems():
        if key[0:4] == 'temp':
            if Decimal(value) > Decimal(config['sensors'][int(key[-1])]['treshold']) or Decimal(value) == 0:
                warningSensors[str(key)] = str(value)
                thisResult = True
                if config['printDebug']:
                    print("WARNING!!! sensor="+str(key)+" value="+str(value)+" treshold="+str(Decimal(config['sensors'][int(key[-1])]['treshold'])))

    return thisResult

getTemperatures()


if config['printDebug']:
    print(temperatures)

mysql = MySQLdb.connect(host=config['mysqlServer'], user=config['mysqlUser'], passwd=config['mysqlPass'], db=config['mysqlDB'])


if isWarningStatus():
    warningCounter = int(getCurrentWarningCounter()[0]) + 1
    for trigger in config['warnOnIteration']:
        if warningCounter == trigger:
            for key, value in warningSensors.iteritems():
                sensor = str(key)
                value = str(value)
                treshold = str(Decimal(config['sensors'][int(key[-1])]['treshold']))
                desc = str(config['sensors'][int(key[-1])]['description'])
                tstamp = str(temperatures['timestamp'])
                originTstamp = getOriginWarningTimestamp()[0]
                if config['emailEnabled']:
                    sendEmail(sensor, treshold, value, desc, tstamp, originTstamp)
            if config['printDebug']:
                print("sending warning:"+str(warningSensors))
else:
    warningCounter = 0

if config['printDebug']:
    print("warning counter="+str(warningCounter))
    print("\nINSERT INTO "+str(config['mysqlDB'])+"."+str(config['mysqlTable']))
    print("timestamp="+str(temperatures['timestamp'])+"  warningCount="+str(warningCounter))
    print("temp_1="+str(temperatures['temp_1'])+" temp_2="+str(temperatures['temp_2'])+" temp_3="+str(temperatures['temp_3'])+" temp_4="+str(temperatures['temp_4']))


with mysql:
    cursor = mysql.cursor()
    query = "INSERT INTO "+str(config['mysqlTable'])+" (timestamp, warning_counter, temp_1, temp_2, temp_3, temp_4) VALUES (%s, %s, %s, %s, %s, %s)"
    cursor.execute(query, (
        temperatures['timestamp'],
        warningCounter,
        temperatures['temp_1'],
        temperatures['temp_2'],
        temperatures['temp_3'],
        temperatures['temp_4']
    ))

mysql.close()

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
