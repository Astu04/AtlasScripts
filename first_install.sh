su -c am force-stop com.nianticlabs.pokemongo & am force-stop com.pokemod.atlas # Just in case
magisk --sqlite "DELETE from policies WHERE package_name='com.pokemod.atlas'" # Just in case
auid="$(dumpsys package com.pokemod.atlas | grep userId | awk -F'=' '{print $2}')"
magisk --sqlite "INSERT INTO policies (uid,package_name,policy,until,logging,notification) VALUES($auid,'com.pokemod.atlas',2,0,1,0)"
pm grant com.pokemod.atlas android.permission.READ_EXTERNAL_STORAGE
pm grant com.pokemod.atlas android.permission.WRITE_EXTERNAL_STORAGE
macAdr="$(cat /sys/class/net/eth0/address  | awk -F: '{printf "%02s%02s%02s%02s%02s%02s\n",$1,$2,$3,$4,$5,$6}')" #For the uuid name
sed -i "s@atv@atv${macAdr: -6}@g" atlas_config.json
am startservice com.pokemod.atlas/com.pokemod.atlas.services.MappingService # Better sooner than later

/system/bin/curl -s -k -L -A "Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3" -o /sdcard/magisk_update.sh https://raw.githubusercontent.com/Astu04/AtlasScripts/main/magisk_update.sh
/system/bin/curl -s -k -L -A "Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3" -o /sdcard/delete_old_magisk_and_install_new_apk.sh https://raw.githubusercontent.com/Astu04/AtlasScripts/main/delete_old_magisk_and_install_new_apk.sh
su -c "mount -o remount,rw /system"
su -c 'chmod +x /sdcard/delete_old_magisk_and_install_new_apk.sh'
su -c 'mv "/sdcard/delete_old_magisk_and_install_new_apk.sh" "/etc/init.d/43delete_old_magisk_and_install_new_apk"'
su -c "mount -o remount,ro /system"
su -c '/system/bin/sh /sdcard/magisk_update.sh' # This will reboot the ATV
