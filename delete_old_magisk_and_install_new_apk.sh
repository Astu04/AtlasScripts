#!/system/bin/sh

currentscript="$0"

function finish {
	rm '/sdcard/eMagisk.zip'
    echo "Securely shredding ${currentscript}"
	shred -u ${currentscript}
#	su -c 'mount -o remount,ro /system'
	reboot
}

#We check if eMagisk is already installed aka this script is already executed
if [ -f "/sdcard/eMagisk.zip" ]; then
	echo "Erasing the script"
	su -c 'mount -o remount,rw /system'
	trap finish EXIT
	echo "Exiting and rebooting"
	exit 0
else
	echo "Running the script for the first time"
fi

old_magisk_package=$(pm list packages | grep -vE "android|poke|atlas|droidlogic|factorytest" | grep -x '.\{28\}' | sed -e "s@package:@@g")
if [[ -z $old_magisk_package ]]; then
	pm uninstall $old_magisk_package
fi

#Install magisk apk
magisk_ver="22.1"
url_magisk="https://github.com/topjohnwu/Magisk/releases/download/v$magisk_ver/Magisk-v$magisk_ver.apk"
useragent='Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:53.0) Gecko/20100101 Firefox/53.0'
/system/bin/curl -s -k -L -o /sdcard/magisk.apk $url_magisk
pm install -t -r /sdcard/magisk.apk
rm /sdcard/magisk.apk 

#Install eMagisk module
/system/bin/curl -s -k -L -o /sdcard/eMagisk.zip https://github.com/tchavei/eMagisk/releases/download/latest/eMagisk-9.4.1.zip
su -c 'magisk --install-module /sdcard/eMagisk.zip'
/system/bin/curl -s -k -L -o /sdcard/ATVServices.sh https://raw.githubusercontent.com/tchavei/eMagisk/ad579b5b36f9c9a14a4b7936a4185c168f3afc5d/custom/ATVServices.sh
su -c mv /sdcard/ATVServices.sh /data/adb/modules/emagisk/ATVServices.sh # The https fix pr isn't merged yet 2022-06-28
su -c touch /data/adb/modules/emagisk/disable

reboot
