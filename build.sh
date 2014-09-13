#!/bin/bash

# Written by cybojenix <anthonydking@gmail.com>
# Rewrtten by skyinfo <sh.skyinfo@gmail.com>
# credits to Rashed for the base of zip making
# credits to the internet for filling in else where


daytime=$(date +%d"-"%m"-"%Y"_"%H"-"%M)

location=.
kernelname=SKernel
vendor=lge


if [ -z $target ]; then
    echo "Select Model to build SKernel"
    echo "1) L5: E610: NFC"
    echo "2) L5: E612: No NFC"
    read -p "Selection : " choice
    case "$choice" in
        1 ) export target=e610 ; export defconfig=cyanogenmod_m4_defconfig;;
        2 ) export target=e612 ; export defconfig=cyanogenmod_m4_nonfc_defconfig;;
        * ) echo "Invalid choice"; sleep 2 ; $0;;
esac
fi # [ -z $target ]

if [ -z $version ]; then
read -p "Version : " kernelver
export version=$kernelver
fi # [ -z $target ]

if [ -z $compiler ]; then
    if [ -f ../arm-eabi-4.6/bin/arm-eabi-* ]; then
        export compiler=../arm-eabi-4.6/bin/arm-eabi-
    elif [ -f arm-eabi-4.6/bin/arm-eabi-* ]; then # [ -f ../arm-eabi-4.6/bin/arm-eabi-* ]
        export compiler=arm-eabi-4.6/bin/arm-eabi-
    else # [ -f arm-eabi-4.6/bin/arm-eabi-* ]
        echo "Please specify Compiler full path"
        read compiler
    fi # [ -z $compiler ]
fi # [ -f ../arm-eabi-4.6/bin/arm-eabi-* ]

cd $location
export ARCH=arm
export CROSS_COMPILE=$compiler
if [ -z "$clean" ]; then
    read -p "Do make clean mrproper?(y/n)" clean
fi # [ -z "$clean" ]
case "$clean" in
    y|Y ) echo "Cleaning..."; make clean mrproper;;
    n|N ) echo "Proceeding to build";;
    * ) echo "Invalid option"; sleep 2 ; build.sh;;
esac

echo "Proceeding to build SKernel"

START=$(date +%s)

make $defconfig
make -j `cat /proc/cpuinfo | grep "^processor" | wc -l` "$@"

## the zip creation
if [ -f arch/arm/boot/zImage ]; then

    rm -f zip-creator/kernel/zImage
    rm -rf zip-creator/system/

    # changed antdking "clean up mkdir commands" 04/02/13
    mkdir -p zip-creator/system/lib/modules

    cp arch/arm/boot/zImage zip-creator/kernel
    # changed antdking "now copy all created modules" 04/02/13
    # modules
    # (if you get issues with copying wireless drivers then it's your own fault for not cleaning)

    find . -name *.ko | xargs cp -a --target-directory=zip-creator/system/lib/modules/

    zipfile="$kernelname-$kernelver-$target-$daytime.zip"
    cd zip-creator
    rm -f *.zip
    zip -r $zipfile * -x *kernel/.gitignore*

    echo "zip saved to zip-creator/$zipfile"

else # [ -f arch/arm/boot/zImage ]
    echo "the build failed so a zip won't be created"
fi # [ -f arch/arm/boot/zImage ]

END=$(date +%s)
BUILDTIME=$((END - START))
B_MIN=$((BUILDTIME / 60))
B_SEC=$((BUILDTIME - E_MIN * 60))
echo -ne "\033[32mBuildtime: "
[ $B_MIN != 0 ] && echo -ne "$B_MIN min(s) "
echo -e "$B_SEC sec(s)\033[0m"
