###############################################################################
# Makefile for the project Medidor_RPM
###############################################################################

## General Flags
PROJECT = Medidor_RPM
MCU = atmega48
TARGET = Medidor_RPM.elf
CC = avr-gcc

CPP = avr-g++

## Options common to compile, link and assembly rules
COMMON = -mmcu=$(MCU)

## Compile options common for all C compilation units.
CFLAGS = $(COMMON)
CFLAGS += -Wall -gdwarf-2 -std=gnu99     -DF_CPU=8000000UL -Os -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
CFLAGS += -MD -MP -MT $(*F).o -MF dep/$(@F).d 

## Assembly specific flags
ASMFLAGS = $(COMMON)
ASMFLAGS += $(CFLAGS)
ASMFLAGS += -x assembler-with-cpp -Wa,-gdwarf2

## Linker flags
LDFLAGS = $(COMMON)
LDFLAGS +=  -Wl,-Map=Medidor_RPM.map


## Intel Hex file production flags
HEX_FLASH_FLAGS = -R .eeprom -R .fuse -R .lock -R .signature

HEX_EEPROM_FLAGS = -j .eeprom
HEX_EEPROM_FLAGS += --set-section-flags=.eeprom="alloc,load"
HEX_EEPROM_FLAGS += --change-section-lma .eeprom=0 --no-change-warnings


## Objects that must be built in order to link
OBJECTS = Medidor_RPM.o LCDlib.o serie.o funciones.o ConversorADC.o 

## Objects explicitly added by the user
LINKONLYOBJECTS = 

## Build
all: $(TARGET) Medidor_RPM.hex Medidor_RPM.eep Medidor_RPM.lss size

## Compile
Medidor_RPM.o: ../Medidor_RPM.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

LCDlib.o: ../LCDlib.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

serie.o: ../serie.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

funciones.o: ../funciones.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

ConversorADC.o: ../ConversorADC.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

##Link
$(TARGET): $(OBJECTS)
	 $(CC) $(LDFLAGS) $(OBJECTS) $(LINKONLYOBJECTS) $(LIBDIRS) $(LIBS) -o $(TARGET)

%.hex: $(TARGET)
	avr-objcopy -O ihex $(HEX_FLASH_FLAGS)  $< $@

%.eep: $(TARGET)
	-avr-objcopy $(HEX_EEPROM_FLAGS) -O ihex $< $@ || exit 0

%.lss: $(TARGET)
	avr-objdump -h -S $< > $@

size: ${TARGET}
	@echo
	@avr-size -C --mcu=${MCU} ${TARGET}

## Clean target
.PHONY: clean
clean:
	-rm -rf $(OBJECTS) Medidor_RPM.elf dep/* Medidor_RPM.hex Medidor_RPM.eep Medidor_RPM.lss Medidor_RPM.map


## Other dependencies
-include $(shell mkdir dep 2>NUL) $(wildcard dep/*)

