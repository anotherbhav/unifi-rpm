#!/bin/bash

## script from: https://github.com/anotherbhav/unifi-pkg-builder
## - please visit repo for more info

## Change these variables here or toggle them from the CLI
### --- Static Variables START ---
PKGTYPE="rpm" # we are building an RPM package
PKGNAME="unifi"
VERSION="5.4.11" # can't get version from the Unifi.unix.zip file... not sure where it is
FILE_PATH="./UniFi.unix.zip" # by default, search the current directory

# for RPM's this gets added on after the version
# useful if you are testing multiple builds of the same version
ITERVER="1.el7.xyzcorp"

BUILDROOT_DIR="/data/rpmbuild/build/BUILDROOT" # where the package version will get built; 'installed'
PKG_DIR="/data/rpmbuild/build/RPMS/x86_64" # where the install package will end up

### --- Static Variables END ---


### Define alert messages, colors and debugging functions
DEBUG=false
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

### Display the help information to the user
printhelp() {
    SCRIPT=$(basename $0)
    echo "$SCRIPT [--option1 value] [--option2 value] [--option3 value]"
    echo "options:"
    echo "-h, --help                     shows this screen"
    echo "-d, --debug                    print debug output (this should be the first flag)"
    echo "--verbose                      alias for --debug"
    echo "-f, --file                     point to a file on the local disk (don't download)"
    echo "-b,--buildversion              Build Version - this is the version aka 4.7.6"
    echo "-i,--iteration                    Iteration Version, useful if testing installs of the same pkg"
}



# ### If no arguments were passed, print the help information
# if [ $# -eq 0 ] ; then
#     loggdebug "No CLI arguments found, using static variables"
#     echo "No arguments found on the CLI"
# fi

while test $# -gt 0; do
        case "$1" in
                -d|--debug|-v|--verbose)
                        DEBUG=true
                        shift
                        ;;
                -h|--help)
                        printhelp
                        exit 0
                        ;;
                -b|--buildversion)
                        shift
                        VERSION="$1"
                        echoinfo "set target build version $VERSION"
                        shift
                        ;;
                -i|--iteration)
                        shift
                        ITERVER="$1"
                        loggdebug "set iteration version: $ITERVER"
                        shift
                        ;;
                -f|--file)
                        shift
                        FILE_PATH="$1"
                        loggdebug "file that you need to build: $VERSION"
                        shift
                        ;;
                *)
                        break
                        ;;
        esac
done




ls "$BUILDROOT_DIR" > /dev/null 2>&1
if [ $? -gt 0 ] ; then
    echofail "BUILDROOT directory does not exist: $BUILDROOT_DIR"
    exit 1
fi

ls "$PKG_DIR" > /dev/null 2>&1
if [ $? -gt 0 ] ; then
    echofail "PKG_DIR directory does not exist: $PKG_DIR"
    exit 1
fi

which fpm > /dev/null 2>&1
if [ $? -gt 0 ] ; then
    echofail "can't Find FPM in executable paths"
    echofail "get it from here: https://github.com/jordansissel/fpm"
    exit 1
fi


echo "# Unifi Package Builder"
echo "- This script will build a package for Ubiquiti's UniFi controller from the open source zip"
echo "- Package:   $PKGNAME"
echo "- Version:   $VERSION"
echo "- Iteration: $ITERVER"
echo "- BuildRoot: $BUILDROOT_DIR"
echo "- Final Dir: $PKG_DIR"
echo
echo

SCRIPT="${0##*/}"
SCRIPT_PATH="${0%/*}"

loggdebug "loading absolute path"
cd "$SCRIPT_PATH"
SCRIPT_PATH=""$(pwd -P)""
# SCRIPT_PATH="${SCRIPT_PATH%/*}"
cd -
loggdebug "Script Path is: $SCRIPT_PATH"
loggdebug "Script is: $SCRIPT"



TMPDIR="/tmp/unifi-build-${RANDOM}"

loggdebug "creating temporary directory as: $TMPDIR"
mkdir "$TMPDIR"


ls "$FILE_PATH" > /dev/null 2>&1
if [ $? -gt 0 ] ; then
  echofail "Could not find zip file: $FILE_PATH"
  echofail "Exiting"
  exit 1
fi

cp "$FILE_PATH" "$TMPDIR"
FNAME=`basename ${FILE_PATH}`

loggdebug "cd into temporary directory"
cd "$TMPDIR"

loggdebug "current working directory: $PWD"
echoinfo "uncompress $FNAME"
unzip "$FNAME" > /dev/null 2>&1

if [ $? -gt 0 ] ; then
  echofail "Error Uncompressing archive: $FNAME"
  echofail "exiting"
  exit 1
fi


loggdebug "create new directory structure for target install"
mkdir -p usr/lib/
mv UniFi usr/lib/unifi

loggdebug "rewrite mongodb symbolic link"
# re-writing the location of mongodb executable
# in CentOS its not the same as the UniFi package
rm -f usr/lib/unifi/bin/mongod
ln -s /bin/mongod usr/lib/unifi/bin/mongod > /dev/null 2>&1

loggdebug "remove readme.txt that comes with install pkg"
rm -f usr/lib/unifi/readme.txt


loggdebug "creating systemd directory"
mkdir -p usr/lib/systemd/system

loggdebug "adding systemd startup file"
cp -v "${SCRIPT_PATH}/conf-files/unifi.service" "usr/lib/systemd/system/unifi.service" > /dev/null 2>&1

if [ $? -gt 0 ] ; then
  echowarn "Error adding the systemd startup file"
fi


loggdebug "creating data directory"
mkdir -p usr/lib/unifi/data

loggdebug "adding systemd startup file"
cp -v "${SCRIPT_PATH}/conf-files/system.properties.sample" "usr/lib/unifi/data/system.properties.sample" > /dev/null 2>&1

if [ $? -gt 0 ] ; then
  echowarn "Error adding the sample system.propeties file to unifi/data/"
fi


echoinfo "Creating the install directory within BUILDROOT"
INSTALLDIR="${BUILDROOT_DIR}/${PKGNAME}-${VERSION}"
mkdir -v "$INSTALLDIR"
if [ $? -gt 0 ] ; then
    echofail "could not create install dir $INSTALLDIR"
    exit 1
fi

echoinfo "move files to the install directory"
mv -v usr "$INSTALLDIR" > /dev/null 2>&1

if [ $? -gt 0 ] ; then
    echofail "could not move files to install DIR"
    echofail "error with: mv -v usr $INSTALLDIR "
    exit 1
fi

# copy scripts
# These scripts are not installed on the system
# they are used durint the upgrade process
loggdebug "creating scripts directory"
mkdir -p scripts

echoinfo "move scripts into directory"
cp -v "${SCRIPT_PATH}/conf-files/before-upgrade.sh" "scripts/" > /dev/null 2>&1
cp -v "${SCRIPT_PATH}/conf-files/after-upgrade.sh" "scripts/" > /dev/null 2>&1

echoinfo "move script files to the install directory"
mv -v scripts "$INSTALLDIR" > /dev/null 2>&1

if [ $? -gt 0 ] ; then
    echofail "could not move files to install DIR"
    echofail "error with: mv -v scripts $INSTALLDIR"
    exit 1
fi


# if you let the group have write permissions, these files
# are not included by FPM. - unsure why
chmod -R g-w "$INSTALLDIR"

echoinfo "using FPM to build the package"

loggdebug "using following variables in FPM command:"
loggdebug " -t ${PKGTYPE} \\"
loggdebug " -n ${PKGNAME} \\"
loggdebug " -v ${VERSION} \\"
loggdebug " --iteration ${ITERVER} \\"
loggdebug " --before-upgrade $INSTALLDIR/scripts/before-upgrade.sh \\"
loggdebug " --after-upgrade $INSTALLDIR/scripts/after-upgrade.sh \\"
loggdebug " --package \"$PKG_DIR\" \\"
loggdebug " -C \"${INSTALLDIR}\" usr/"
echo
echoinfo "--- fpm output starts ---"
fpm \
-s dir \
-t ${PKGTYPE} \
-n ${PKGNAME} \
-v ${VERSION} \
--iteration ${ITERVER} \
-d java-1.7.0-openjdk \
-d mongodb-server \
-d mongodb \
--description 'Ubiquiti UniFi Controller' \
--license 'GPLv3' \
--url 'https://www.ubnt.com/download/unifi/unifi-ap' \
--config-files /usr/lib/unifi/data/ \
--before-upgrade $INSTALLDIR/scripts/before-upgrade.sh \
--after-upgrade $INSTALLDIR/scripts/after-upgrade.sh \
--package "$PKG_DIR" \
-C "${INSTALLDIR}" usr/
echoinfo "--- fpm output ends ---"

echoinfo "cleaning up"
loggdebug "remove tmp dir $TMPDIR"
rm -rf "$TMPDIR"
