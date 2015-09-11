###############################################################################
# Makefile for the project RPM_Base
###############################################################################

## General Flags
PROJECT = RPM_Base
MCU = atmega48
TARGET = RPM_Base.elf
CC = avr-gcc

CPP = avr-g++

## Options common to compile, link and assembly rules
COMMON = -mmcu=$(MCU)

## Compile options common for all C compilation units.
CFLAGS = $(COMMON)
CFLAGS += -Wall -gdwarf-2 -std=gnu99   -DF_CPU=8000000UL -Os -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
CFLAGS += -MD -MP -MT $(*F).o -MF dep/$(@F).d 

## Assembly specific flags
ASMFLAGS = $(COMMON)
ASMFLAGS += $(CFLAGS)
ASMFLAGS += -x assembler-with-cpp -Wa,-gdwarf2

## Linker flags
LDFLAGS = $(COMMON)
LDFLAGS +=  -Wl,-Map=RPM_Base.map


## Intel Hex file production flags
HEX_FLASH_FLAGS = -R .eeprom -R .fuse -R .lock -R .signature

HEX_EEPROM_FLAGS = -j .eeprom
HEX_EEPROM_FLAGS += --set-section-flags=.eeprom="alloc,load"
HEX_EEPROM_FLAGS += --change-section-lma .eeprom=0 --no-change-warnings


## Objects that must be built in order to link
OBJECTS = RPM_Base.o ConversorADC.o funciones.o LCDlib.o serie.o 

## Objects explicitly added by the user
LINKONLYOBJECTS = 

## Build
all: $(TARGET) RPM_Base.hex RPM_Base.eep RPM_Base.lss size

## Compile
RPM_Base.o: ../RPM_Base.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

ConversorADC.o: ../ConversorADC.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

funciones.o: ../funciones.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

LCDlib.o: ../LCDlib.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

serie.o: ../serie.c
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
	-rm -rf $(OBJECTS) RPM_Base.elf dep/* RPM_Base.hex RPM_Base.eep RPM_Base.lss RPM_Base.map


## Other dependencies
-include $(shell mkdir dep 2>NUL) $(wildcard dep/*)

