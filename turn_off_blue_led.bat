@echo off
adb tcpip 5555
for /F "tokens=*" %%A in (DeviceIP.txt) do (
adb connect %%A
adb -s %%A shell "su -c 'echo 0 > /sys/class/leds/led-sys/brightness'"
)
pause
