adb tcpip 
for /F "tokens=*" %%A in (DeviceIP.txt) do (
adb connect %%A
adb -s %%A shell "su -c am force-stop com.nianticlabs.pokemongo & am force-stop com.pokemod.atlas"
adb -s %%A shell "am startservice com.pokemod.atlas/com.pokemod.atlas.services.MappingService"
)
pause
