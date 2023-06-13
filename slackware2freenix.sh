#!/bin/bash
#######################################################################
# Slackware(64)-15.0 to Freenix(64)-15.0 script, all three parts:
# Remove nonfree packages, build & install libre kernel & firmware
# written by krt@beauxbead.com / krt.beauxbead.com
# Released under the WTFPL 2.0  http://www.wtfpl.net/
#
# This is intended to be run as root. It builds the latest Linux-libre
# kernel for your architecture from the same branch as the upstream
# stock kernel. Works on both 32-bit and 64-bit installations of
# Slackware 15.0 .
#
# No guarantees are given, this script is highly experimental.
# Feel free to make changes and share with the community.
#######################################################################

# remove and blacklist non-free packages
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% remove and blacklist non-free packages'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
./remove-blacklist-nonfree-packages.sh
# Build and install linux-libre kernel packages
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% build and install Linux-libre kernel packages'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
INSTALL_KERNEL='yes' ./linux-libre-kernel-builder-installer.sh
# Build and install linux-libre firmware package
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% build and install Linux-libre firmware package'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
INSTALL_FIRMWARE='yes' ./linux-libre-firmware-builder-installer.sh
# Say goodbye...
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% You are now fully liberated, you can reboot the system.'
echo '% This script does not clean up after itself, you can'
echo '% manually remove the files in /tmp/, however the packages'
echo '% and SlackBuilds that resulted from this process are there'
echo '% in case you want to save or share them for any reason.'
echo '% '
echo '% See https://freenix.net/ for more information.'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

exit 0
