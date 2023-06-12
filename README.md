A project in the works to convert an installed Slackware-15.0 system into a Freenix-15.0 system.
Both 64-bit and 32-bit versions can be converted.

There are 4 scripts in total:

1)  slackware2freenix.sh

This is a meta-script that just runs the other three without any arguments.
Needs to be run as root.


2)  remove-blacklist-nonfree-packages.sh

This removes and blacklists all non-free packages as per freenix.net.
This script can probably be run on any Slackware-based derivative, as long as slackpkg is present.

arguments:

BLACKLISTFILE = the location of your slackpkg blacklist file (default = /etc/slackpkg/blacklist)


3)  linux-libre-kernel-build-instsall.sh

This builds and installs the Linux-Libre kernel, headers, modules.
Modifies stock kernel-configs and SlackBuild files.

arguments:

STOCKVERSION = version of stock kernel to use kernel-configs from (default grabs latest from repo)

MAJORVERSION = branch of libre kernel to build from (defaults to stock kernel branch, i.e. 5.15)

LIBREVERSION = version of Linux-libre acutally being builg (defaults to latest version in MAJORVERSION branch)

RELEASE = release version of Slackware (i.e. 15.0). Fetches from running system by default.

REPOURL = URL of your preferred repo.  (default = https://mirrors.slackware.com)

BUILDDIR = directory to build kernels in. (default =/tmp/linux-libre-4-freenix)

BLACKLISTFILE = the location of your slackpkg blacklist file (default = /etc/slackpkg/blacklist)

INSTALL_KERNEL = install packages after building them (default = no)


4)  linux-libre-firmware-build-install.sh

This builds and installs the Linux-libre firmware.
Modifies stock SlackBuild file.

arguments:

RELEASE = release version of Slackware (i.e. 15.0). Fetches from running system by default.

REPOURL = URL of your preferred repo.  (default = https://mirrors.slackware.com)

BUILDDIR = directory to build kernels in. (default =/tmp/linux-libre-4-freenix)

BLACKLISTFILE = the location of your slackpkg blacklist file (default = /etc/slackpkg/blacklist)

INSTALL_FIRMWARE = install packages after building them (default = no)


NOTE:  The script DOES NOT clean up after itself.
You are invited to delete any leftover files and directories in /tmp/ .
However, the modified SlackBuild scripts and kernel packages all reside there.
You may want to save or share these before clearing out /tmp/ .
