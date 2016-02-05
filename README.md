# Description
- a script to build the UniFi Controller as an RPM
    - https://www.ubnt.com/download/unifi
- Why? UniFi does not provide a package for CentOS 7 so here is a script to build one

# Usage
Get this script:
`git clone https://github.com/anotherbhav/unifi-pkg-builder.git`
`cd build-unifi-rpm`

Download Unifi Pkg you want to build:
`curl -OL http://dl.ubnt.com/unifi/4.8.12/UniFi.unix.zip`

Build the Package with some flags defined:
`./build-unifi-rpm.sh --buildversion 4.8.12 --file UniFi.unix.zip --iteration 1.el7.xyzcorp`

Verify built package if you want:
`rpm -qpi /data/rpmbuild/build/RPMS/x86_64/unifi-4.8.12-1.el7.xyzcorp.x86_64.rpm`

# Variables
- modify the Static Variables at the beginning of the script if you want to run the script without commands
- modify the script if you want to modify the build/BUILDROOT/ and build/RPM/ dirs

# Other
Get some help: `./build-unifi-rpm.sh --help`
