@echo off
adb tcpip 5555
for /F "tokens=*" %%A in (DeviceIP.txt) do (
	adb connect %%A
	adb -s %%A install -r "PokemodAtlas-Public-v22052602_2.apk"
	adb -s %%A install -r "com.nianticlabs.pokemongo_0.237.0-2022050401_minAPI23(arm64-v8a)(nodpi)_apkmirror.com.apk"
	adb -s %%A push atlas_config.json /data/local/tmp/atlas_config.json
	adb -s %%A push emagisk.config /data/local/tmp/emagisk.config
	adb -s %%A shell '/system/bin/curl -s -k -L -A "Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3" -o /sdcard/first_install.sh https://raw.githubusercontent.com/Astu04/AtlasScripts/main/first_install.sh'
	adb -s %%A shell "su -c '/system/bin/sh /sdcard/first_install.sh'"
	adb -s %%A shell "rm /sdcard/first_install.sh"
)
pause
