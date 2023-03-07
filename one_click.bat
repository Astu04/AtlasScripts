@echo off
adb tcpip 5555
for /F "tokens=*" %%A in (DeviceIP.txt) do (
	adb connect %%A
	adb -s %%A install -r "PokemodAtlas-Public-v22071801.apk"
	adb -s %%A install -r "com.nianticlabs.pokemongo_0.263.1-2023022801_minAPI24(arm64-v8a)(nodpi)_apkmirror.com.apk"
	adb -s %%A push atlas_config.json /data/local/tmp/atlas_config.json
	adb -s %%A push emagisk.config /data/local/tmp/emagisk.config
	if exist authorized_keys (
		adb -s %%A push authorized_keys /sdcard/authorized_keys
	)
	if exist onBoot.sh (
		adb -s %%A push onBoot.sh /sdcard/onBoot.sh
		adb -s %%A shell "chmod +x /sdcard/onBoot.sh"
		adb -s %%A shell "su -c 'mount -o remount,rw /system'"
		adb -s %%A shell "echo 'sh /sdcard/onBoot.sh' > /sdcard/44onBoot"
		adb -s %%A shell "chmod +x /sdcard/44onBoot"
		adb -s %%A shell "su -c mv /sdcard/44onBoot /etc/init.d/44onBoot"
	)
	adb -s %%A shell "/system/bin/curl -s -k -L https://raw.githubusercontent.com/Astu04/AtlasScripts/main/first_install.sh | su -c sh"
)
pause
