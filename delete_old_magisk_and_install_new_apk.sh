#!/system/bin/sh
old_magisk_package=$(pm list packages | grep -vE "android|poke|atlas|droidlogic|factorytest" | grep -x '.\{28\}' | sed -e "s@package:@@g")
if [[ -z $old_magisk_package ]]; then
	pm uninstall $old_magisk_package
fi

#Install magisk apk
magisk_ver="22.1"
url_magisk="https://github.com/topjohnwu/Magisk/releases/download/v$magisk_ver/Magisk-v$magisk_ver.apk"
useragent='Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:53.0) Gecko/20100101 Firefox/53.0'
/system/bin/curl -s -k -L -o /sdcard/magisk.apk $url_magisk
pm install -t -r /sdcard/magisk
rm /sdcard/magisk.apk 

#Install eMagisk module
/system/bin/curl -s -k -L -o /sdcard/eMagisk.zip https://github.com/tchavei/eMagisk/releases/download/latest/eMagisk-9.4.1.zip
su -c 'magisk --install-module /sdcard/eMagisk.zip'

reboot
