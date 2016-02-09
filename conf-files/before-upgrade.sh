#!/bin/bash

# unifi-pkg-builder before-upgrade script
# a script run BEFORE the upgrade process on a UniFi Controller
# this uses systemd

PKGNAME='unifi'

systemctl status $PKGNAME

if [ $? -eq 0 ] ; then
  systemctl stop $PKGNAME

  NOW=`date`
  while [ 1 ]
    D=`date -d"$NOW"`
    sleep 1
    systemctl status $PKGNAME

    if [ $? -gt 0 ] ; then
      # process has exited successfully
      # its safe to continue
      break
    fi
  done
fi
