#!/system/bin/sh
# Credits to https://github.com/Map-A-Droid/MAD-ATV/blob/master/42mad
# I just deleted code to keep the part where it updates magisk
# and I edited the magisk url

#magisk version / url
magisk_ver="20.4"
url_magisk="https://github.com/topjohnwu/Magisk/releases/download/v20.4/Magisk-v20.4.zip"
url_gapps="https://madatv.b-cdn.net/open_gapps-arm64-7.1-pico-20200715.zip"
rgcconf="/data/data/de.grennith.rgc.remotegpscontroller/shared_prefs/de.grennith.rgc.remotegpscontroller_preferences.xml"
pdconf="/data/data/com.mad.pogodroid/shared_prefs/com.mad.pogodroid_preferences.xml"
useragent='Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:53.0) Gecko/20100101 Firefox/53.0'
ip="$(ifconfig 'eth0'|awk '/inet addr/{print $2}'|cut -d ':' -f 2)"

requires_autoconf=1
reboot_required=0
cachereboot=0

download(){
# $1 = url
# $2 = local path
# lets see that curl exits successfully
until /system/bin/curl -s -k -L -A "$useragent" -o "$2" "$1" ;do
    sleep 15
done
}

log_msg() {
# $1 = severity
# $2 = msg
    echo "$msg"
}

wait_for_network(){
echo "Waiting for network"
until ping -c1 8.8.8.8 >/dev/null 2>/dev/null; do
    "No network detected.  Sleeping 10s"
    sleep 10
done
echo "Network connection detected"
}

repack_magisk(){
log_msg 2 "Starting Magisk repackaging"
monkey -p com.topjohnwu.magisk 1
sleep 30
input tap 39 42
sleep 5
input tap 150 537
sleep 5
input tap 315 552
sleep 5
input keyevent 61
sleep 2
input keyevent 61
sleep 2
input keyevent 66
sleep 2
}

install_magisk() {
download "$url_magisk" /sdcard/magisk.zip
mkdir -p /cache/recovery
touch /cache/recovery/command
echo '--update_package=/sdcard/magisk.zip' >> /cache/recovery/command
cachereboot=1
}

check_magisk(){
# We'll attempt to do this a little early since apparently people get impatient
if [[ -f /sbin/magisk ]] ;then
    log_msg 2 "Setting Magisk permissions"
    /sbin/magiskhide --add com.nianticlabs.pokemongo
    [[ -f /sdcard/magisk.zip ]] && rm /sdcard/magisk.zip
    [[ -f /sdcard/smali.zip ]] && rm /sdcard/smali.zip
fi
# Install magisk.  If it already exists, check for an update
if ! [[ -f /sbin/magisk ]] ;then
    log_msg 2 "Preparing Magisk installation"
    touch /sdcard/magisk_repackage
    install_magisk
elif ! magisk -c|grep -q "$magisk_ver"; then
    log_msg 2 "Updating Magisk"
    touch /sdcard/magisk_update
    install_magisk
elif [[ -f /sdcard/magisk_repackage ]] ;then
    log_msg 2 "Magisk repackaging required"
    # After installation the manager may not be fully installed.  Wait for it to show then repackage
    until [[ $(pm list packages com.topjohnwu.magisk) ]] ;do
        sleep 10
    done
    r=0
    while [[ $(pm list packages com.topjohnwu.magisk) ]] ;do
        sleep 10
        # if repackaging didnt take place in 200 seconds, try again
        if ! (( $((r%20)) )); then
            log_msg 2 "Attempting to repackage magisk"
            repack_magisk
        fi
        r=$((r+1))
    done
    log_msg 2 "Magisk successfully repackaged"
    rm -f /sdcard/magisk_repackage
    sleep 10
elif [[ -f /sdcard/magisk_update ]] ;then
    while [[ $(pm list packages com.topjohnwu.magisk) ]] ;do
        pm uninstall com.topjohnwu.magisk
        sleep 3
    done
    rm -f /sdcard/magisk_update
elif [[ $(pm list packages com.topjohnwu.magisk) ]] ;then
    log_msg 4 "Magisk manager is installed and not repackaged. This should not happen. Please report it and tell us if you were installing or updating."
fi
}

################ start of execution
wait_for_network
mount -o remount,rw /system
check_magisk
mount -o remount,ro /system
# initdebug
