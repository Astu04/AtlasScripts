#!/system/bin/sh

function finish {
	rm '/sdcard/eMagisk.zip'
	su -c "rm /etc/init.d/43delete_old_magisk_and_install_new_apk"
	# Deleting the eMagisk disable
	su -c rm /data/adb/modules/emagisk/disable
#	su -c 'mount -o remount,ro /system'
	reboot
}

#We check if eMagisk is already installed aka this script is already executed
if [ -f "/sdcard/eMagisk.zip" ]; then
	#Install dropbear ssh
	if [ -f "/sdcard/authorized_keys" ]; then
		/system/bin/curl -s -k -L -o /sdcard/magiskssh.zip https://gitlab.com/d4rcm4rc/MagiskSSH_releases/-/raw/master/magisk_ssh_v0.14.zip?inline=false
		su -c magisk --install-module /sdcard/magiskssh.zip
		rm /sdcard/magiskssh.zip
		su -c mkdir -p /data/ssh/root/.ssh/
		su -c mkdir -p /data/ssh/shell/.ssh/
		su -c cp /sdcard/authorized_keys /data/ssh/root/.ssh/authorized_keys
		su -c mv /sdcard/authorized_keys /data/ssh/shell/.ssh/authorized_keys
		su -c chmod 600 /data/ssh/root/.ssh/authorized_keys
		su -c chmod 600 /data/ssh/shell/.ssh/authorized_keys
		su -c "sed -i 's@#StrictModes yes@StrictModes no@g' /data/ssh/sshd_config"
	fi
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
magisk_ver="23.0"
url_magisk="https://github.com/topjohnwu/Magisk/releases/download/v$magisk_ver/Magisk-v$magisk_ver.apk"
useragent='Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:53.0) Gecko/20100101 Firefox/53.0'
/system/bin/curl -s -k -L -o /sdcard/magisk.apk $url_magisk
pm install -t -r /sdcard/magisk.apk
rm /sdcard/magisk.apk 

#Install eMagisk module
/system/bin/curl -s -k -L -o /sdcard/eMagisk.zip https://github.com/Astu04/eMagisk/releases/download/latest/eMagisk.zip
su -c 'magisk --install-module /sdcard/eMagisk.zip'
su -c touch /data/adb/modules/emagisk/disable

reboot
