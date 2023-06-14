#!/bin/bash
###################################################################################
# Slackware(64)-15.0 to Freenix(64)-15.0 script, part 1:
# Non-free package remover and blacklister
# written by krt@beauxbead.com / krt.beauxbead.com
# Released under the WTFPL 2.0  http://www.wtfpl.net/
#
# This is intended to be run ONCE as root on a fully updated stock system.
# It removes all non-free packages (as deemed by freenix.net) and adds each
# one to the system blacklist.
#
# Works on both 32-bit and 64-bit installations of Slackware 15.0, as well as
# ARM-based Slackware variants and other derivatives (not fully tested).
#
# No guarantees are given, this script is highly experimental.
# Feel free to make changes and share with the community.
#
####################################################################################

# Set blacklist file, just in case...
BLACKLISTFILE=${BLACKLISTFILE:-'/etc/slackpkg/blacklist'}

# Remove non-free stock packages from full stock installation
# Comment out any you'd like to keep
removepkg \
  amp \
  bluez-firmware \
  font-bh-ttf \
  font-bh-type1 \
  ipw2100-fw \
  ipw2200-fw \
  mozilla-firefox \
  mozilla-thunderbird \
  seamonkey \
  skkdic \
  unarj \
  xgames \
  zd1211-firmware \

# Add non-free packages to blacklist if not already blacklisted
if ! grep -q 'Non-free packages removed as per freenix.net' $BLACKLISTFILE ; then

# Comment out any to be excluded from blacklist
echo '#' >> $BLACKLISTFILE
echo '##############################################' >> $BLACKLISTFILE
echo '# Non-free packages removed as per freenix.net' >> $BLACKLISTFILE
echo 'amp' >> $BLACKLISTFILE
echo 'bluez-firmware' >> $BLACKLISTFILE
echo 'font-bh-ttf' >> $BLACKLISTFILE
echo 'font-bh-type1' >> $BLACKLISTFILE
echo 'ipw2100-fw' >> $BLACKLISTFILE
echo 'ipw2200-fw' >> $BLACKLISTFILE
echo 'mozilla-firefox' >> $BLACKLISTFILE
echo 'mozilla-thunderbird' >> $BLACKLISTFILE
echo 'seamonkey' >> $BLACKLISTFILE
echo 'skkdic' >> $BLACKLISTFILE
echo 'unarj' >> $BLACKLISTFILE
echo 'xgames' >> $BLACKLISTFILE
echo 'zd1211-firmware' >> $BLACKLISTFILE

fi

# Print out new blacklist
cat $BLACKLISTFILE

# All done, now for the kernels....
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% Non-free software is removed and blacklisted.'
echo '% To (re)build a libre kernel for your system, run: '
echo '% ./linux-libre-kernel-builder-installer.sh'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

exit 0
