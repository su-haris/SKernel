#!/bin/bash

# Written by Caio Oliveira aka Caio99BR <caiooliveirafarias0@gmail.com>
# credits to the internet for filling in else where

inchoice() {
echo ""
echo "Script says: Choose to which you will build"; sleep .5
echo "Caio99BR says: 1) L1 II Single"; sleep .5
echo "Caio99BR says: 2) L1 II Dual"; sleep .5
echo "Caio99BR says: 3) L3 II Single"; sleep .5
echo "Caio99BR says: 4) L3 II Dual"; sleep .5
}

devicechoice() {
read -p "Choice: " -n 1 -s choice
case "$choice" in
	1 ) export target="L1"; export serie="II"; export variant="Single"; export defconfig=cyanogenmod_vee1_defconfig;;
	2 ) export target="L1"; export serie="II"; export variant="Dual"; export defconfig=cyanogenmod_vee1ds_defconfig;;
	3 ) export target="L3"; export serie="II"; export variant="Single"; export defconfig=cyanogenmod_vee3_defconfig;;
	4 ) export target="L3"; export serie="II"; export variant="Dual"; export defconfig=cyanogenmod_vee3ds_defconfig;;
	* ) echo "$choice - This option is not valid"; sleep 2; devicechoice;;
esac
echo "$choice - $target $serie $variant"; sleep .5
}

mainprocess() {
inchoice
devicechoice
echo ""
echo "Script says: Choose the place of the toolchain"; sleep .5
echo "Google GCC - 1) 4.7   | 2) 4.8"; sleep .5
echo "Linaro GCC - 3) 4.6.4 | 4) 4.7.4 | 5) 4.8.4"; sleep .5
echo "or any key to Choose the place"; sleep .5
read -p "Choice: " -n 1 -s toolchain
case "$toolchain" in
	1 ) export CROSS_COMPILE="../android_prebuilt_toolchains/arm-eabi-4.7/bin/arm-eabi-";;
	2 ) export CROSS_COMPILE="../android_prebuilt_toolchains/arm-eabi-4.8/bin/arm-eabi-";;
	3 ) export CROSS_COMPILE="../android_prebuilt_toolchains/arm-unknown-linux-gnueabi-linaro_4.6.4-2013.05/bin/arm-unknown-linux-gnueabi-";;
	4 ) export CROSS_COMPILE="../android_prebuilt_toolchains/arm-unknown-linux-gnueabi-linaro_4.7.4-2013.12/bin/arm-unknown-linux-gnueabi-";;
	5 ) export CROSS_COMPILE="../android_prebuilt_toolchains/arm-linux-gnueabi-linaro_4.8.4-2014.11/bin/arm-linux-gnueabi-";;
	* ) toolchainplace;;
esac
echo "$CROSS_COMPILE"; sleep .5
}

toolchainplace() {
echo ""
echo "Script says: Please specify a location"; sleep 1
echo "Script says: and the prefix of the chosen toolchain at the end"; sleep 1
echo "Caio99BR says: GCC 4.6 ex. ../arm-eabi-4.6/bin/arm-eabi-"; sleep 2
read -p "Place: " -s CROSS_COMPILE
}

kernelclean() {
echo "Cleaning..."
make clean mrproper &> /dev/null
}

removelastzip() {
rm -rf zip-creator/*.zip
rm -rf zip-creator/kernel/zImage
rm -rf zip-creator/system/lib/modules
}

coping() {
mkdir -p zip-creator/system/lib/modules
cp arch/arm/boot/zImage zip-creator/kernel
find . -name *.ko | xargs cp -a --target-directory=zip-creator/system/lib/modules/
}

resume() {
echo "Continuing...";
}

continuing() {
echo -ne
}

preloop() {
echo "Just wait"
loop
}

loop() {
LEND=$(date +"%s")
LBUILDTIME=$(($LEND - $START))
echo -ne "\r\033[K"
echo -ne "\033[32mElapsed Time: $(($LBUILDTIME / 60)) minutes and $(($LBUILDTIME % 60)) seconds.\033[0m"
sleep 1
echo -ne "\r\033[K"
looping
}

looping() {
if [ -f zip-creator/*.zip ]; then
	continuing
else
	loop
fi
}

todual() {
sed 's/Single/Dual/' zip-creator/META-INF/com/google/android/updater-script > zip-creator/META-INF/com/google/android/updater-script-temp
rm zip-creator/META-INF/com/google/android/updater-script
mv zip-creator/META-INF/com/google/android/updater-script-temp zip-creator/META-INF/com/google/android/updater-script
}

tosingle() {
sed 's/Dual/Single/' zip-creator/META-INF/com/google/android/updater-script > zip-creator/META-INF/com/google/android/updater-script-temp
rm zip-creator/META-INF/com/google/android/updater-script
mv zip-creator/META-INF/com/google/android/updater-script-temp zip-creator/META-INF/com/google/android/updater-script
}

ziperror() {
echo "Script says: The build failed so a zip won't be created"
}

ziper() {
zipfile="$custom_kernel-$target-$serie-$variant-$version.zip"
cd zip-creator
zip -r $zipfile * -x *kernel/.gitignore*
cd ..
}

buildprocess() {
echo "Building..."
sleep 1
echo
make $defconfig &> /dev/null
make -j `cat /proc/cpuinfo | grep "^processor" | wc -l` "$@"
if [ -f arch/arm/boot/zImage ]; then
	coping

	if [ "$variant" == "Dual" ]; then
		todual
	fi

	ziper

	if [ "$variant" == "Dual" ]; then
		tosingle
	fi
fi
}

scriptrev=8

location=.
custom_kernel=VeeKernel
version=Local

cd $location
export ARCH=arm

echo ""
echo "Caio99BR says: This is an open source script, feel free to use and share it."; sleep .5
echo "Caio99BR says: Kernel Build Script Revision $scriptrev."; sleep .5

removelastzip

echo ""
echo "Script says: Choose."
read -p "Script says: Any key for Restart Building Process or N for Continue: " -n 1 -s clean
case $clean in
	n) resume; inchoice; devicechoice;;
	N) resume; inchoice; devicechoice;;
	*) kernelclean; mainprocess;;
esac

echo ""
echo -e "Script says: Now, building the $custom_kernel for $target $serie $variant $version Edition!"; sleep .5

echo ""
echo "Script says: You want to see the details of kernel build?"
read -p "Script says: Enter any key for Yes or N for No: " -n 1 -t 10 -s clean
START=$(date +"%s")
case $clean in
	n) buildprocess &> /dev/null | preloop;;
	N) buildprocess &> /dev/null | preloop;;
	*) buildprocess;;
esac

if [ -f zip-creator/$zipfile ]; then
	echo -e "\033[36mPackage Complete: zip-creator/$zipfile"
else
	ziperror
fi

END=$(date +"%s")
BUILDTIME=$(($END - $START))
echo -e "\033[32mBuild Time: $(($BUILDTIME / 60)) minutes and $(($BUILDTIME % 60)) seconds.\033[0m"
