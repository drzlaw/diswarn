#!/bin/sh

echo "DisWarn installer started"

echo "Waiting for device..."
adb wait-for-device
echo "Reboot to bootloader"
adb shell reboot bootloader
sleep 5

echo "Boot with root permissions..."
fastboot boot boot/boot-US-adb-root.img
sleep 5

echo "Waiting for device..."
adb wait-for-device
adb remount /system rw

echo "Waiting for device load..."
until [[ -z $(adb shell service check package | grep "not found") ]]
do
    sleep 3
done

echo "Installing msg.apk"
adb install android/msg.apk

echo "Installing scripts"
adb shell mv /system/bin/logwatch /system/bin/logwatch_orig
adb push android/logwatch /system/bin/logwatch
adb push android/diswarn /system/bin/diswarn

echo "Creating config"
adb shell mkdir -p /data/media/0/diswarn
adb push android/diswarn.conf /data/media/0/diswarn/diswarn.conf

echo "Setup permissions"
adb shell chmod 0755 /system/bin/logwatch
adb shell chmod 0755 /system/bin/diswarn
adb shell chmod 0777 /data/media/0/diswarn/diswarn.conf

echo "Reboot..."
adb remount /system ro
adb shell reboot

echo "Done"
