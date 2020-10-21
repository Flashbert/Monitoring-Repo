#!/bin/bash
IP=$1
COMMUNITY=$2
SNMPVERSION=$3
INTERFACE=$4

#Returns the value
STATUS=`snmpget -v ${SNMPVERSION} -c ${COMMUNITY} ${IP} -Oqve .1.3.6.1.2.1.2.2.1.8.$(snmpwalk -v ${SNMPVERSION} -c ${COMMUNITY} ${IP} -On .1.3.6.1.2.1.31.1.1.1.1 | grep ${INTERFACE} | awk '{print $1}' | awk -F. '{print $13}')`

#Check if STATUS is empty (happens if the INTERFACE is not found, if true, then set STATUS to 6 (to avoid error output)
if [ -z $STATUS ]
then
 STATUS=6
fi

echo "Status: $STATUS"
if [ $STATUS -eq 1 ]
then
 echo "OK! - Interface is UP"
 exit 0
else
 echo "Critical! Interface is DOWN"
 exit 2
fi
