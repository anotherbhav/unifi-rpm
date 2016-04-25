#!/bin/bash

# unifi-pkg-builder before-upgrade script
# a script run BEFORE the upgrade process on a UniFi Controller
# this uses systemd
DEBUG=1
PKGNAME='unifi'

loggdebug() {
    echo $DEBUG && echo -e "DEBUG=> $1"
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



systemctl start $PKGNAME
sleep 10

systemctl status $PKGNAME

# See if this fixes the warning after install when running `systemctl status unifi`
systemctl daemon-reload
