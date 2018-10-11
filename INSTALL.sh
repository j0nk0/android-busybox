#!/bin/bash
#=======================================================================
#          FILE:  INSTALL.sh
#         USAGE:  ./INSTALL.sh
#        AUTHOR: j0nk0
#        GITHUB: https://github.com/j0nk0/
#          REPO: https://github.com/j0nk0/android-busybox
#       CREATED: 11.10.2018
#      REVISION: 0.0.2
#=======================================================================
tmp_ndk_workdir="/tmp/android-ndk"
NDKHOME="/usr/local/android-ndk"
APILEVEL="21"
TOOLCHAINHOME="$HOME/arm-linux-androideabi"

if [ $EUID -ne 0 ]; then # Super User Check
	echo -e "[x] Aborted, please execute the script as root."
	exit 1
fi

#If no existing toolchain found, download and install the Android NDK and build toolchain
if [ ! -d $TOOLCHAINHOME ]; then
	echo "Found no existing toolchain."
	echo "Downloading and installing the Android NDK and building toolchain"
	if [ ! -d "/usr/local/android-ndk" ]; then
		mkdir -p $tmp_ndk_workdir &>/dev/null
		cd $tmp_ndk_workdir
		wget "https://dl.google.com/android/repository/android-ndk-r17b-linux-x86_64.zip"
		unzip $tmp_ndk_workdir/android-ndk-*-linux-*.zip
		mv --verbose $tmp_ndk_workdir/android-ndk-*/ $NDKHOME
		rm -r --interactive=always --verbose $tmp_ndk_workdir/ #android-ndk-*-linux-*.zip
	else
		echo "Found existing Android NDK installation in: /usr/local/android-ndk."
	fi

	[ -d /tmp/ndk-root ] && rm -r /tmp/ndk-root

	echo "Building toolchain..."
	cd $NDKHOME
	./build/tools/make-standalone-toolchain.sh --platform=$APILEVEL
	cd /tmp/ndk-root

	tar xjvf arm-linux-androideabi.tar.bz2 -C $HOME/
else
	echo "Found existing toolchain in: $TOOLCHAINHOME"
fi

##Configuring toolchain
#Set API level
sed -i "/\#define __ANDROID_API__ __ANDROID_API_FUTURE__/c\\#define __ANDROID_API__ $APILEVEL" $TOOLCHAINHOME/sysroot/usr/include/android/api-level.h
nano $TOOLCHAINHOME/sysroot/usr/include/android/api-level.h

export PATH="$PATH:$TOOLCHAINHOME/bin"

#If scripts file is not in /tmp/android-busybox, move /tmp/android-busybox and git clone android-busybox repo
if ! [ $(dirname $(realpath $0)) = "/tmp/android-busybox" ]; then
	#Build busybox
	[ -d /tmp/android-busybox ] && mv --verbose --backup=numbered /tmp/android-busybox /tmp/android-busybox_old
	cd /tmp/
	#  git clone https://github.com/sherpya/android-busybox
	git clone https://github.com/j0nk0/android-busybox
fi

cd /tmp/android-busybox

# make config                    # text based configurator (of last resort)
# make defconfig                 # set .config to largest generic configuration
make menuconfig                # interactive curses-based configurator
make sherpya_android_defconfig # Build for sherpya_android
# make android2_defconfig        # Build for android2
# make android_defconfig         # Build for android
# make android_ndk_defconfig     # Build for android_ndk
# make android_502_defconfig     # Build for android_502

make -j4 --always-make --ignore-errors --keep-going

if [ -f /tmp/android-busybox/busybox ]; then
	echo "Succesfully build busybox:"
	ls -lsa /tmp/android-busybox/busybox
else
	echo "Building busybox failed."
fi
