# Description
- a script to build Ubiquiti's [UniFi Controller](https://www.ubnt.com/download/unifi) as a CentOS 7 RPM
- Why? UniFi does not provide a package for CentOS 7 so here is a script to build one

# Dependencies
- [FPM](https://github.com/jordansissel/fpm)

# Usage
Get this script

    $ git clone https://github.com/anotherbhav/unifi-rpm/
    $ cd unifi-pkg-builder


Download Unifi Pkg you want to build  

    $ curl -OL https://www.ubnt.com/downloads/unifi/5.8.3-xxxxxx/UniFi.unix.zip (get this link from the Unifi Beta Forum as the DIY Package)


Build the Package with some flags defined

    $ ./build-unifi-rpm.sh --buildversion 5.8.3.2 --file UniFi.unix.zip --iteration 1.el7.xyzcorp


Verify built package if you want

    $ rpm -qpi /data/rpmbuild/build/RPMS/x86_64/unifi-5.8.3-1.el7.xyzcorp.x86_64.rpm


# Tested Versions
Versions that I have built and used successfully
- 5.8.3
- every previous 4.x build

# Variables
- modify the Static Variables at the beginning of the script if you want to run the script without commands
- modify the script if you want to modify the build/BUILDROOT/ and build/RPM/ dirs

# Other
Get some help: `./build-unifi-rpm.sh --help`
