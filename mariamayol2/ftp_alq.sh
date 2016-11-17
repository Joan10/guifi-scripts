#!/bin/bash
source ./credencials
FILE='today.backup'

cd /data/disc1/backups/Routers


HOST='10.91.9.65'
FNAME=`date +%Y-%m-%d`'.backup'
mkdir -p $HOST
cd $HOST
ftp -n $HOST <<END_SCRIPT
user $USER $PASSWD
binary
get $FILE $FNAME
quit
END_SCRIPT
cd ..

HOST='10.91.9.1'
FNAME=`date +%Y-%m-%d`'.backup'
mkdir -p $HOST
cd $HOST
ftp -n $HOST <<END_SCRIPT
user $USER $PASSWD
binary
get $FILE $FNAME
quit
END_SCRIPT
cd ..

HOST='10.91.9.193'
FNAME=`date +%Y-%m-%d`'.backup'
mkdir -p $HOST
cd $HOST
ftp -n $HOST <<END_SCRIPT
user $USER $PASSWD
binary
get $FILE $FNAME
quit
END_SCRIPT
cd ..

HOST='10.91.246.1'
FNAME=`date +%Y-%m-%d`'.backup'
mkdir -p $HOST
cd $HOST
ftp -n $HOST <<END_SCRIPT
user $USER $PASSWD
binary
get $FILE $FNAME
quit
END_SCRIPT
exit 0
cd ..
