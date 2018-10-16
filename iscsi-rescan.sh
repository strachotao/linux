#!/bin/bash
# iscsi rescan; version 2016-07-22; strachotao

ls -l /dev/sd*

echo " Scan Physical for New LUNs ..."
ls /sys/class/scsi_host/ | while read HOST
do
   echo ${HOST}
   echo "Scan Host: - ${HOST} ..."
   echo "- - -" > /sys/class/scsi_host/${HOST}/scan
done
echo "New LUNs ..."
fdisk -l | grep /dev/sd

ls -l /dev/sd*
