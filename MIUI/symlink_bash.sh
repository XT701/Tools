#!/system/bin/sh

export PATH=/system/bin:/system/xbin:$PATH
mount -o remount,rw /system
ln -sf /system/bin/bash /system/xbin
mount -o remount,ro /system
