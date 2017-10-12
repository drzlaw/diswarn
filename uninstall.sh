#!/bin/sh

echo "DisWarn uninstaller started"

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

echo "Uninstalling msg.apk"
adb uninstall com.android.msg

echo "Uninstalling scripts and config"
adb shell mv /system/bin/logwatch_orig /system/bin/logwatch
adb shell rm /system/bin/diswarn
adb shell rm /system/bin/diswarn_message
adb shell rm /system/bin/diswarn_scenario.txt

echo "Reboot..."
adb remount /system ro
adb shell reboot

echo "Done"
