;--------Lectura de la eeprom
.include "m48def.inc"
.org 0
	rjmp	eep_notrdy
;------------USO DE LA EEPROM
.org 0x1A
eep_notrdy:
	sbic	EECR,1		;salta si EEWE clear
	rjmp	eep_notrdy	;espera a que esté lista la eeprom
read:
	ldi 	ZL, 0x01
	out		EEARL, ZL
	sbi		EECR, EERE		;set EERE (Read-strobe) low
	nop
	nop
	in 		r0, EEDR
eep_notrdy2:
	sbic	EECR,1
	rjmp	eep_notrdy2
write:
	LDI		ZL, 0x00
	OUT		EEARL, ZL
	OUT		EEDR, R0
	CLI
	SBI		EECR, EEMWE
	SBI		EECR, EEWE
	SEI
;---------USO DE LOS PUERTOS DE ENTRADA SALIDA
	SBI		DDRB, DDB1
	CBI		PORTB, PB1
	SBI		PORTB, PB1
	LDI		R18, 0x02
	OUT		DDRB, R18
	LDI		R18, 0x00
	OUT		PORTB, R18
	LDI		R18, 0x02
	OUT		PORTB, R18
	LDI		R18, 0x00
	OUT		DDRB, R18
	LDI		R18, 0xFF
	OUT 	PORTB, R18
	IN 		R18, PINB
;-----------USO DE LA SRAM INTERNA
	LDI		ZL, 0x00
	LDI		ZH, 0x01
SRAM1:
	ST		Z+, R18
	LD		R3, Z+
;----------USO DE LOS TIMERS
	LDI		R18, 0xFD
	OUT		TCNT0, R18
	LDI		R18, 0x01
	OUT		TCCR0B, R18
TIMER:
	SBIS	TIFR0, TOV0
	RJMP	TIMER
	IN		R18, TIFR0	

	RJMP 	SRAM1
