@echo off
adb tcpip 5555
for /F "tokens=*" %%A in (DeviceIP.txt) do (
	adb connect %%A
	adb -s %%A install -r "PokemodAtlas-Public-v22052602_2.apk"
	adb -s %%A install -r "com.nianticlabs.pokemongo_0.237.0-2022050401_minAPI23(arm64-v8a)(nodpi)_apkmirror.com.apk"
	adb -s %%A push atlas_config.json /data/local/tmp/atlas_config.json
	adb -s %%A push emagisk.config /data/local/tmp/emagisk.config
	adb -s %%A push authorized_keys /sdcard/authorized_keys
	adb -s %%A shell "/system/bin/curl -s -k -L https://raw.githubusercontent.com/Astu04/AtlasScripts/main/first_install.sh | su -c sh"
)
pause
