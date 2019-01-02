# Description
- a script to build Ubiquiti's [UniFi Controller](https://www.ubnt.com/download/unifi) as a CentOS 7 RPM
- Why? UniFi does not provide a package for CentOS 7 so here is a script to build one

# Dependencies
- [FPM](https://github.com/jordansissel/fpm)

# Usage
Get this script

    $ git clone https://github.com/anotherbhav/unifi-rpm/
    $ cd unifi-rpm


Set the target and iteration version

    export TARGET=5.8.24
    export ITERATION=1.el7.xyzcorp


Download Unifi pkg you want to build (this link should work, otherwise get this link from the UniFi Beta Forum as the DIY Package). If the package is available on the official ubnt.com downloads site then it should work with the command below.

    curl -OL https://www.ubnt.com/downloads/unifi/${TARGET}/UniFi.unix.zip


Build the Package with some flags defined

    ./build-unifi-rpm.sh


Verify built package if you want

    rpm -qpi /data/rpmbuild/build/RPMS/x86_64/unifi-${TARGET}-${ITERATION}.x86_64.rpm

# Notes

- backup of existing DB is created to `/var/tmp/unifi_backup_*.tar`

## Upgrade Notes

- on upgrade the following things automatically happen
- unifi service is stopped before upgrade
- backup is created to `/var/tmp/unifi_backup_*.tar`
  - this takes a WHILE becuase the mongo DB is usually multiple GB in size to backup
  - the line it freezes on for me is `Running transaction`
  - if you want to track the backup size you can pop another terminal and run 'watch ls -lhart /var/tmp/'
- upgrade is performed
- unifi service is restarted


# Tested Versions
Versions that I have built and used (usually through upgrade) successfully
- 5.9.29 (tested 2019-01-02)
- 5.8.24 (tested 2018-08-13)
- 5.7.24 (tested 2018-08-13)
- 5.7.20 (tested 2018-05-11) - requires java1.8
- 5.6.22 (tested 2017-12-27)
- 5.5.20
- 5.4.11
- 5.3.8
- every previous 4.x build

# Variables
- modify the Static Variables at the beginning of the script if you want to run the script without commands
- modify the script if you want to modify the build/BUILDROOT/ and build/RPM/ dirs

# Other
Get some help: `./build-unifi-rpm.sh --help`

## Build RPM with without env Variables

Build the Package with some flags defined

    ./build-unifi-rpm.sh --buildversion $TARGET --file UniFi.unix.zip --iteration 1.el7.xyzcorp
