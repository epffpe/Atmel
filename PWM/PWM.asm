.include "m48def.inc"

.DEF	TEMP = R16
.ORG	0x00
	RJMP	RESET

.ORG 	0x1A
RESET:
	SER		TEMP
	OUT		DDRD, TEMP
	LDI		TEMP, (1<<COM0A1)|0x3
	OUT		TCCR0A, TEMP
	LDI		TEMP, 0x1A
	OUT		OCR0A, TEMP
	LDI		TEMP, (1<<CS00)
	OUT		TCCR0B, TEMP
LOOP:
	RJMP 	LOOP
	.EXIT
