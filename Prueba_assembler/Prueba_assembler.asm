.INCLUDE "m48def.inc"
.EQU	TABLE_SIZE=5
;------------------------------
.DSEG
	VAR1:	.BYTE 1
	TABLE: 	.BYTE TABLE_SIZE
;-------------------------------
.CSEG
.ORG	0
	RJMP	RESET
.ORG 	0x1A
RESET:
	CLR		R0
	;CLZ
	BCLR	1
	LDI		R16,(1+5)
	LDI		R30, LOW(VAR1)
	LDI		R31, HIGH(VAR1)
LOOP:
	LD		R2, Z+
	CPSE	R16, R30
	RJMP	LOOP
	
LOOP2:
	RJMP	LOOP2

.EXIT
