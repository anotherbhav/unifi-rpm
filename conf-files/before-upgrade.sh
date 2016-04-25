#!/bin/bash

# unifi-pkg-builder before-upgrade script
# a script run BEFORE the upgrade process on a UniFi Controller
# this uses systemd
DEBUG=1
PKGNAME='unifi'

loggdebug() {
    $DEBUG && echo -e "DEBUG=> $1"
}
echopass () {
   echo -e "\e[00;32mPASS\e[00m: $1"
}

echofail () {
   echo -e "\e[00;31mFAIL\e[00m: $1"
}

echowarn () {
   echo -e "\e[00;33mWARN\e[00m: $1"
}

echoinfo () {
   echo -e "\e[00;35mINFO\e[00m: $1"
}



systemctl status $PKGNAME

# if [ $? -eq 0 ] ; then
#   systemctl stop $PKGNAME
#
#   NOW=`date`
#   while [ 1 ]
#     D=`date -d"$NOW"`
#     sleep 1
#     systemctl status $PKGNAME
#
#     if [ $? -gt 0 ] ; then
#       # process has exited successfully
#       # its safe to continue
#       break
#     fi
#   done
# fi

echodebug "stop unifi controller"
systemctl stop $PKGNAME
sleep 10

systemctl status $PKGNAME

TARGET_FNAME=`date "+unifi_backup_%Y-%m-%d_%H%M.tar"`
echodebug "target file path is: $TARGET_PATH"

TARGET_PATH="/var/tmp/$TARGET_FNAME"
echodebug "target path is: $TARGET_PATH"

echodebug "cd to unifi backup dir"
cd /usr/lib/unifi/data/
echodebug "cwd $PWD"

tar cvzf $TARGET_PATH .
echopass "backup created: $TARGET_PATH"

cd -
