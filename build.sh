#!/bin/bash

# Written by Caio Oliveira aka Caio99BR <caiooliveirafarias0@gmail.com>
# Rewritten by Suhail aka skyinfo <sh.skyinfo@gmail.com>
# credits to the internet for filling in else where

inchoice() {
echo ""
echo "Choose the device to build for!"; sleep .5
echo "1) L5 E610 (NFC)"; sleep .5
echo "2) L5 E612 (No NFC)"; sleep .5
echo "3) L7 P700 (NFC)"; sleep .5
echo "4) L7 P705 (No NFC)"; sleep .5
}

devicechoice() {
read -p "Choice: " -n 1 -s choice
case "$choice" in
	1 ) export target="e610"; export defconfig=skernel_m4_defconfig;;
	2 ) export target="e612"; export defconfig=skernel_m4_nonfc_defconfig;;
	3 ) export target="p700"; export defconfig=skernel_u0_defconfig;;
	4 ) export target="p705"; export defconfig=skernel_u0_nonfc_defconfig;;
	* ) echo "$choice - This option is not valid"; sleep 2; devicechoice;;
esac
echo "$choice - $target "; sleep .5
}

mainprocess() {
inchoice
devicechoice
echo ""
echo "Choose the place of the toolchain"; sleep .5
echo "Google GCC - 1) 4.7   | 2) 4.8"; sleep .5
echo "Linaro GCC - 3) 4.6.4 | 4) 4.7.4 | 5) 4.8.4 | 6) 4.9.3"; sleep .5
echo "or any key to Choose the place"; sleep .5
read -p "Choice: " -n 1 -s toolchain
case "$toolchain" in
	1 ) export CROSS_COMPILE="../android_prebuilt_toolchains/arm-eabi-4.7/bin/arm-eabi-";;
	2 ) export CROSS_COMPILE="../android_prebuilt_toolchains/arm-eabi-4.8/bin/arm-eabi-";;
	3 ) export CROSS_COMPILE="../android_prebuilt_toolchains/arm-unknown-linux-gnueabi-linaro_4.6.4-2013.05/bin/arm-unknown-linux-gnueabi-";;
	4 ) export CROSS_COMPILE="../android_prebuilt_toolchains/arm-unknown-linux-gnueabi-linaro_4.7.4-2013.12/bin/arm-unknown-linux-gnueabi-";;
	5 ) export CROSS_COMPILE="../android_prebuilt_toolchains/arm-linux-gnueabi-linaro_4.8.4-2014.11/bin/arm-linux-gnueabi-";;
	6 ) export CROSS_COMPILE="../android_prebuilt_toolchains/arm-cortex-linux-gnueabi-linaro_4.9.3-2015.03/bin/arm-cortex-linux-gnueabi-";;
	* ) toolchainplace;;
esac
echo "$CROSS_COMPILE"; sleep .5
}

toolchainplace() {
echo ""
echo "Please specify a location"; sleep 1
echo "and the prefix of the chosen toolchain at the end"; sleep 1
echo "Caio99BR says: GCC 4.6 ex. ../arm-eabi-4.6/bin/arm-eabi-"; sleep 2
read -p "Place: " -s CROSS_COMPILE
}

kernelclean() {
echo "Do you want to clean (make clean)?"
read -p #Needs to be fixed
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
#Needs to be fixed
tosingle() {
sed 's/Dual/Single/' zip-creator/META-INF/com/google/android/updater-script > zip-creator/META-INF/com/google/android/updater-script-temp
rm zip-creator/META-INF/com/google/android/updater-script
mv zip-creator/META-INF/com/google/android/updater-script-temp zip-creator/META-INF/com/google/android/updater-script
}

ziperror() {
echo "The build failed so a zip won't be created"
}

ziper() {
zipfile="$custom_kernel-$target-$serie-$variant-$version.zip"
cd zip-creator
zip -r $zipfile * -x *kernel/.gitignore*
cd ..
}

#Needs to be fixed
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
custom_kernel=SKernel
version=M7

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
echo -e "Now, building the $custom_kernel for $target $version Edition!"; sleep .5

echo ""
echo "You want to see the details of kernel build?"
read -p "Enter any key for Yes or N for No: " -n 1 -t 10 -s clean
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
