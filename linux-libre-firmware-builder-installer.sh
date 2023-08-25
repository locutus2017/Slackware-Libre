#!/bin/bash
#######################################################################
# Slackware(64)-Libre script, part 3
# Linux-Libre firmware builder and installer
# written by krt@beauxbead.com / krt.beauxbead.com
# Released under the WTFPL 2.0  http://www.wtfpl.net/
#
# This is intended to be run as root. It builds the latest Linux-libre
# firmware and upgrades the stock firmware package to the libre one.
# Works on both 32-bit and 64-bit installations of Slackware 15.0.
# Slackware derivatives might also work, this is untested though.
#
# No guarantees are given, this script is highly experimental.
# Feel free to make changes and share with the community.
#######################################################################

# where is this script being run from?
CWD0=$(pwd)

# future proof the release version number
# to-do:  make this work on -current?
RELEASE=${RELEASE:-$(grep '^VERSION=' /etc/os-release | cut -d '=' -f 2 | sed 's/"//g')}

# Uses mirrors.slackware.com to find a mirror near you, feel free to change to a local mirror
REPOURL=${REPOURL:-'https://mirrors.slackware.com'}

# prepare for kernel building
BUILDDIR=${BUILDDIR:-'/tmp/slackware-libre'}

# Set blacklist file, just in case...
BLACKLISTFILE=${BLACKLISTFILE:-'/etc/slackpkg/blacklist'}

# Set variable to 'yes' to install package after building:
INSTALL_FIRMWARE=${INSTALL_FIRMWARE:-'no'}

# download linux-libre firmware
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% Downloading Linux-Libre firmware'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

rm -r ${BUILDDIR}/firmware
mkdir ${BUILDDIR}
mkdir ${BUILDDIR}/firmware
cd ${BUILDDIR}/firmware
wget $REPOURL/slackware/slackware64-$RELEASE/source/a/kernel-firmware/kernel-firmware.SlackBuild
wget $REPOURL/slackware/slackware64-$RELEASE/source/a/kernel-firmware/slack-desc
cp kernel-firmware.SlackBuild kernel-firmware-gnu.SlackBuild
chmod a+x kernel-firmware-gnu.SlackBuild

# patch SlackBuild and slack-desc to fit linux-libre-firmware using:
# sed -i 's/ --- / --- /' slack-desc
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% Patching SlackBuild and slack-desc files for linux-libre'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
# patch kernel-firmware.SlackBuild
sed -i 's/PKGNAM=kernel-firmware/PKGNAM=kernel-firmware-gnu/' kernel-firmware-gnu.SlackBuild
sed -i 's/.*git.kernel.org\/pub\/scm\/linux\/kernel\/git\/firmware\/linux-firmware.git\/commit\/?id=HEAD | grep "   committer " | head -n 1 | rev | cut -f 3 -d.*/  DATE="$(lynx -dump -width=256 https:\/\/jxself.org\/git\/linux-libre-firmware.git | grep "last change" | head -n 1 | cut -f 2 -d "," |  cut -d" " -f2-4 | tr -d " ")"/' kernel-firmware-gnu.SlackBuild
sed -i 's/https:\/\/git.kernel.org\/pub\/scm\/linux\/kernel\/git\/firmware\/linux-firmware.git\/commit\/?id=HEAD | grep "    commit   " | head -n 1 | cut -f 2 -d ] | cut -b 1-7/"https:\/\/jxself.org\/git\/?p=linux-libre-firmware.git;a=commit" | grep "   commit    " | head -n 1 | cut -b 14-20/' kernel-firmware-gnu.SlackBuild
sed -i 's/git:\/\/git.kernel.org\/pub\/scm\/linux\/kernel\/git\/firmware\/linux-firmware.git/https:\/\/jxself.org\/git\/linux-libre-firmware.git/' kernel-firmware-gnu.SlackBuild
sed -i 's/kernel-firmware-$/kernel-firmware-gnu-$/' kernel-firmware-gnu.SlackBuild
sed -i 's/( cd linux-firmware/(cd linux-libre-firmware/' kernel-firmware-gnu.SlackBuild
# leave out ARM-based firmware, cross-compiler required.  Build everything else
sed -i 's/make DESTDIR=$PKG $INSTALLTARGET/make DESTDIR=$PKG a56 as31 ath9k_htc_toolchain ath9k_htc b43-tools carl9170fw-toolchain carl9170fw cis-tools cis dsp56k ihex2fw isci keyspan_pda openfwwf usbdux $INSTALLTARGET/' kernel-firmware-gnu.SlackBuild
sed -i 's/kernel-firmware-${DATE}/kernel-firmware-gnu-${DATE}/' kernel-firmware-gnu.SlackBuild
# patch slack-desc
sed -i 's/kernel-firmware/kernel-firmware-gnu/' slack-desc
sed -i 's/kernel-firmware (Firmware for the kernel)/kernel-firmware-gnu (Firmware for the kernel)/' slack-desc
sed -i 's/Linux/Linux-libre/' slack-desc
sed -i 's/git.kernel.org\/pub\/scm\/linux\/kernel\/git\/firmware\/linux-firmware.git/jxself.org\/git\/linux-libre-firmware.git/' slack-desc

# build firmware package
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% Building Linux-Libre firmware'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

TMP=${BUILDDIR}/firmware ./kernel-firmware-gnu.SlackBuild

if [ $INSTALL_FIRMWARE == 'no' ]; then

# that should do it!
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% Linux-libre firmware has been built.'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
cd ${CWD0}

exit 0

fi

# Remove stock firmware package
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% Removing stock firmware package'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
removepkg kernel-firmware

# install firmware package
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% Installing Linux-Libre firmware'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

installpkg ${BUILDDIR}/firmware/kernel-firmware-gnu*

# Add non-free packages to blacklist if not already blacklisted
if ! grep -q 'kernel-firmware' $BLACKLISTFILE ; then

# Blacklist stock firmware package
echo 'kernel-firmware' >> $BLACKLISTFILE

# Print out new blacklist
cat $BLACKLISTFILE
fi

# that should do it!
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% Linux-libre firmware has been built and installed.'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
cd ${CWD0}

exit 0
