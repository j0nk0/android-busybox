#!/bin/bash
#By j0nk0 [https://github.com/j0nk0/]
  tmp_="/tmp/android-ndk"
  NDKHOME="/usr/local/android-ndk"
  APILEVEL="21"

 if [ $EUID -ne 0 ]; then # Super User Check
   echo -e "[x] Aborted, please execute the script as root."; exit 1
 fi

#If no toolchain found, download and install the Android NDK and build toolchain
   if which arm-linux-androideabi-cpp  &>/dev/null; then
     apt remove -y gcc-arm-linux-androideabi
   fi

   if [ ! -d "/usr/local/android-ndk" ]; then
    mkdir -p $tmp_ &>/dev/null
    cd $tmp_
    wget "https://dl.google.com/android/repository/android-ndk-r17b-linux-x86_64.zip"
     unzip $tmp_/android-ndk-*-linux-*.zip
     mv --verbose $tmp_/android-ndk-*/ $NDKHOME
     rm --interactive=always --verbose $tmp_/android-ndk-*-linux-*.zip
   else
    echo "Android NDK already installed in /usr/local/android-ndk.  Skipping."
   fi

   if [ -d /tmp/ndk-root ];then
      rm -r /tmp/ndk-root
   fi

   cd $NDKHOME
    ./build/tools/make-standalone-toolchain.sh --platform=$APILEVEL
   cd /tmp/ndk-root

   if [ -d $HOME/arm-linux-androideabi ] ; then
       rm -r $HOME/arm-linux-androideabi
   fi
    tar xjvf arm-linux-androideabi.tar.bz2 -C $HOME/

#Configuring toolchain
#Set API level
   sed -i "/\#define __ANDROID_API__ __ANDROID_API_FUTURE__/c\\#define __ANDROID_API__ $APILEVEL" $HOME/arm-linux-androideabi/sysroot/usr/include/android/api-level.h
   nano $HOME/arm-linux-androideabi/sysroot/usr/include/android/api-level.h
   export PATH=$PATH:$HOME/arm-linux-androideabi/bin

#Build busybox
  if [ -d /tmp/android-busybox ];then
   mv --verbose --backup=numbered /tmp/android-busybox /tmp/android-busybox_old
  fi
  cd /tmp/
  git clone https://github.com/sherpya/android-busybox
   cd /tmp/android-busybox

   make sherpya_android_defconfig
   make menuconfig
   make -j4 --always-make --ignore-errors --keep-going
   if [ -f /tmp/android-busybox/busybox ]; then
    echo "Succesfully build busybox:"
     ls -lsa /tmp/android-busybox/busybox
   else
    echo "Building busybox failed."
   fi
