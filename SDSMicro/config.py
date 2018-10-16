#!/usr/bin/python
"""
    config file; version 2015-10-16; strachotao
    Parse SDS Micro's temperatures http://{sds-micro-ip}/temp.xml and save it into MySQL database
    This is a configuration file for the core script
"""

config = {
    'sensors' : {
        1 : {'enabled' : True, 'treshold' : '24.00', 'description' : 'Serverovna A1'},
        2 : {'enabled' : True, 'treshold' : '24.00', 'description' : 'Serverovna A2'},
        3 : {'enabled' : True, 'treshold' : '24.00', 'description' : 'Serverovna B1'},
        4 : {'enabled' : True, 'treshold' : '24.00', 'description' : 'Serverovna B2'}
    },

    'warnOnIteration' : (3, 25, 60, 120, 300, 500),

    'errorEmailHour' : (2, 8, 14, 20),
    'errorEmailMinute' : (10),

    'XMLSource' : 'http://10.0.1.233/temp.xml',

    'mysqlServer' : '127.0.0.1',
    'mysqlDB' : 'sdsmicro',
    'mysqlPort' : '3306',
    'mysqlTable' : 'temp_history',
    'mysqlUser' : 'sds-micro',
    'mysqlPass' : 'passwd',

    'emailEnabled' : True,
    'emailFrom' : 'temperature@localhost',
    'emailTo' : (
        'oldrich@strachota.net',
        'root@localhost'
    ),
    'emailSMTP' : 'localhost',

    'printDebug' : False
}

temperatures = {}
warningSensors = {}
warningCounter = 0
tempHistory = []
