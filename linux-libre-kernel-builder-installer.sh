#!/bin/bash
#######################################################################
# Slackware(64)-Libre script, part 2:
# Linux-Libre kernel builder and package installer
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

# where is this script being run from?
CWD0=$(pwd)

# Set blacklist file, just in case...
BLACKLISTFILE=${BLACKLISTFILE:-'/etc/slackpkg/blacklist'}

# Set variable to 'yes' to install packages after building:
INSTALL_KERNEL=${INSTALL_KERNEL:-'no'}

# future proof the release version number
# to-do:  make this work on -current?
RELEASE=$(grep '^VERSION=' /etc/os-release | cut -d '=' -f 2 | sed 's/"//g')

# prepare for kernel building
BUILDDIR=${BUILDDIR:-'/tmp/slackware-libre'}
rm -r ${BUILDDIR}
mkdir ${BUILDDIR}
cd ${BUILDDIR}

# Uses mirrors.slackware.com to find a mirror near you, feel free to change to a local mirror
REPOURL=${REPOURL:-'https://mirrors.slackware.com'}
# Set latest stock version here
STOCKVERSION=${STOCKVERSION:-$(wget -q -O - $REPOURL/slackware/slackware64-$RELEASE/patches/source/ | grep -o -P '(?<=>linux-).*(?=\/<)')}

# download kernel SlackBuild scripts
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% Downloading stock kernel SlackBuild files.'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/kernel-generic.SlackBuild
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/kernel-headers.SlackBuild
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/kernel-modules.SlackBuild
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/kernel-source.SlackBuild
chmod a+x *.SlackBuild

# use olddefconfig instead of oldconfig to accept defaults since last stock kernel update.
sed -i 's/oldconfig/olddefconfig/' kernel-generic.SlackBuild
sed -i 's/oldconfig/olddefconfig/' kernel-modules.SlackBuild
sed -i 's/oldconfig/olddefconfig/' kernel-source.SlackBuild

# use MAJORVERSION to change branches if you wish
MAJORVERSION=${MAJORVERSION:-$(wget -q -O - $REPOURL/slackware/slackware64-$RELEASE/patches/source/ | grep -o -P '(?<=>linux-).*(?=\/<)' | sed 's/\.[^.]*$//')}

# download latest Linux-Libre source in the same branch as the stock kernel
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% Downloading Linux-Libre source.'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
wget -r -l1 -np -nd "http://linux-libre.fsfla.org/pub/linux-libre/releases/LATEST-${MAJORVERSION}.N" -A "linux-libre-${MAJORVERSION}.*-gnu.tar.lz*"
wget -r -l1 -np -nd "http://linux-libre.fsfla.org/pub/linux-libre/releases/LATEST-${MAJORVERSION}.N" -A "linux-libre-${MAJORVERSION}.*-gnu.tar.sign"
wget http://linux-libre.fsfla.org/pub/linux-libre/SIGNING-KEY.linux-libre
gpg --import SIGNING-KEY.linux-libre
gpg --verify *tar.lz.sign
LIBREVERSION=${LIBREVERSION:-$(ls linux-libre-*-gnu.tar.lz | sed 's/[^0-9.]*//g' | sed 's/..$//')}

ln -s linux-libre-${LIBREVERSION}-gnu.tar.lz linux-${LIBREVERSION}.tar.lz

# grab most recent stock kernel-configs and use them as latest libre-configs
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% Downloading stock kernel-configs for use with libre-kernel.'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
mkdir kernel-configs
cd kernel-configs
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/kernel-configs/config-generic-${STOCKVERSION} -O config-generic-${LIBREVERSION}
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/kernel-configs/config-generic-${STOCKVERSION}.x64 -O config-generic-${LIBREVERSION}.x64
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/kernel-configs/config-generic-smp-${STOCKVERSION}-smp -O config-generic-smp-${LIBREVERSION}-smp
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/kernel-configs/config-huge-${STOCKVERSION} -O config-huge-${LIBREVERSION}
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/kernel-configs/config-huge-${STOCKVERSION}.x64 -O config-huge-${LIBREVERSION}.x64
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/kernel-configs/config-huge-smp-${STOCKVERSION}-smp -O config-huge-smp-${LIBREVERSION}-smp
cd ../

# Grab slack-desc files for packaging later
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% Downloading slack-desc files for kernel-packages.'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
mkdir slack-desc
cd slack-desc
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/slack-desc/slack-desc.kernel-generic-smp.i686
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/slack-desc/slack-desc.kernel-generic.i586
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/slack-desc/slack-desc.kernel-generic.x86_64
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/slack-desc/slack-desc.kernel-headers
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/slack-desc/slack-desc.kernel-huge-smp.i686
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/slack-desc/slack-desc.kernel-huge.i586
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/slack-desc/slack-desc.kernel-huge.x86_64
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/slack-desc/slack-desc.kernel-modules_template
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/slack-desc/slack-desc.kernel-source
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/slack-desc/slack-desc.kernel-source.vanilla
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/slack-desc/slack-desc.kernel-template
cd ../

# Build Linux-Libre packages
wget $REPOURL/slackware/slackware64-$RELEASE/patches/source/linux-${STOCKVERSION}/build-all-kernels.sh
chmod +x build-all-kernels.sh
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% Now building the kernels using Pat`s script, this may take some time.'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
INSTALL_PACKAGES=NO  ./build-all-kernels.sh
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% We are done with Pat`s script. Thanks Pat!'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

if [ $INSTALL_KERNEL == 'no' ]; then

# that should do it!
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% Linux-libre kernel packages have been built.'
echo '% The last step is to build the firmware package, do this by running:'
echo '% ./linux-libre-firmware-builder-installer.sh'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
cd ${CWD0}

exit 0

fi

# Upgrade kernel packages all at once
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% Upgrading stock kernel packages to libre kernel packages.'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
upgradepkg /tmp/output-*/kernel-*.t?z

# Now generate new initrd and update the bootloader
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% Running genintird and lilo.'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
geninitrd
lilo

# Add non-free packages to blacklist if not already blacklisted
if ! grep -q 'Kernel packages removed to prevent stock kernel being reinstalled' $BLACKLISTFILE ; then

# Blacklist stock kernel packages
echo '#' >> $BLACKLISTFILE
echo '###################################################################' >> $BLACKLISTFILE
echo '# Kernel packages removed to prevent stock kernel being reinstalled' >> $BLACKLISTFILE
echo 'kernel-generic.*' >> $BLACKLISTFILE
echo 'kernel-headers.*' >> $BLACKLISTFILE
echo 'kernel-huge.*' >> $BLACKLISTFILE
echo 'kernel-modules.*' >> $BLACKLISTFILE
echo 'kernel-source' >> $BLACKLISTFILE
echo 'kernel.*' >> $BLACKLISTFILE

# Print out new blacklist
cat $BLACKLISTFILE

fi

# that should do it!
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo '% Stock kernel packages have been upgraded to libre kernel packages.'
echo '% The last step is to upgrade the firmware package, do this by running:'
echo '% ./linux-libre-firmware-builder-installer.sh'
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
cd ${CWD0}

exit 0
