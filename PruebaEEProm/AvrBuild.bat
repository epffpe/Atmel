@ECHO OFF
"C:\Archivos de programa\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "D:\Designs\Atmel\PruebaEEProm\labels.tmp" -fI -W+ie -o "D:\Designs\Atmel\PruebaEEProm\eeprom.hex" -d "D:\Designs\Atmel\PruebaEEProm\eeprom.obj" -e "D:\Designs\Atmel\PruebaEEProm\eeprom.eep" -m "D:\Designs\Atmel\PruebaEEProm\eeprom.map" "D:\Designs\Atmel\PruebaEEProm\eeprom.asm"
