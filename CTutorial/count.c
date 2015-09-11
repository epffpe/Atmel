/*/*
 * FILE: count.c - Binary down counter for the GNU C Tutorial.
 */

#include <avr/io.h>

int main(void)
{
	unsigned char value;

	/* Set PORT B direction to output*/
	DDRB = 0xFF;

	/* Initialise value */
	value = 0xFF;

	/* Run forever - "for(;;)" is the same as "while(1)" */
	for (;;) {
		/* Write value to Port B */
		PORTB = value;

		/* Decrement value */
		value--;
	}
	return 0;
}
