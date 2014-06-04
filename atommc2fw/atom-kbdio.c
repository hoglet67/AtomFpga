/*
	Atom-kbdio	: IO and Keyboard routines for the Acorn Atom.

	2009-07-28, P.Harvey-Smith.
	
	Implements the following :
	
	1) PS/2 Keyboard interface, driving crosspoint switch connected to
	   Atom keyboard interface.
	
	2) Bi-directional Data bus between the Atom and the AVR, hardware 
	   implemented in an external CPLD.
	   
	3) SD/MMC interface for Atom.
	
	When the Atom writes to the external latch an inturrupt is generated 
	at the AVR, which reads the byte from the latch and sends it to the MMC
	by SPI. The incoming byte reply byte from the SPI is then written back
	to the Atom. In this way the AVR becomes a smart I/O controler for the
	Atom.
	
	This method should also be adaptable to other 8 bit micros, perticually
	those based upon 65x2 and 68xx processors.
	
	2009-09-05 Added the ability to the keyboard module to hadle both the
	normal and escaped scancodes, this allows us to treat for example
	left and right ctrl differently and the numeric keypad keys differently
	from the ins block and seperate cursors.
	
	2009-09-06 Added the ability to reset the Atom from the keyboard by 
	pressing the break key, this is achieved by attaching PD3 of the AVR to
	the 6502 reset line. Normally it is configured as an input and allowed 
	to float. When break is pressed the pin is re-configured as an output and
	sent low, and then after a delay sent high again.
	
	2011-05-25 Ported the new keyboard handling code to the Atom, this fixes 
	several long standing hang bugs with the keyboard code, and should hopefully
	be much more stable.
	
*/

#include <avr/interrupt.h>
#include <inttypes.h>
#include <util/delay.h>
#include "ps2kbd.h"
#include "ps2scancode.h"
#include "status.h"
#include "mt8816.h"
#include "matrix_kbd.h"
#include "atomio.h"
#include "mmc/integer.h"
#include "mmc/atmmc2.h"

// Global data for MMC

unsigned char globalData[256];
char windowData[512];
BYTE configByte;
BYTE blVersion;

extern WORD globalAmount;

#ifdef INCLUDE_SDDOS
unsigned char sectorData[512];
#endif

#define LED_DELAY	150

// Toggle the PS/2 leds so that the user knows the system is ready.
void flag_init(void)
{
	uint8_t	leds = 0;
	
	ps2_kbd_set_leds(leds);	_delay_ms(LED_DELAY);
	leds|=KBD_LED_SCROLL;
	ps2_kbd_set_leds(leds);	_delay_ms(LED_DELAY);
	leds|=KBD_LED_CAPS;
	ps2_kbd_set_leds(leds);	_delay_ms(LED_DELAY);
	leds|=KBD_LED_NUMLOCK;
	ps2_kbd_set_leds(leds);	_delay_ms(LED_DELAY);

	leds&=~KBD_LED_SCROLL;
	ps2_kbd_set_leds(leds);	_delay_ms(LED_DELAY);
	leds&=~KBD_LED_CAPS;
	ps2_kbd_set_leds(leds);	_delay_ms(LED_DELAY);
	leds&=~KBD_LED_NUMLOCK;
	ps2_kbd_set_leds(leds);	_delay_ms(LED_DELAY);
}

void key_callback(uint8_t	scancode,
				  uint8_t	state)
{
	if(state==KEY_DOWN)
	{
		switch(scancode)
		{
			case SCAN_CODE_F10 :
				log0("\n");
				log0("%d\n",globalData);
				HexDumpHead(&globalData,256,0);
				break;
		}
	}
}

int main(void)
{
	uint8_t	old = EIFR;
	
	Serial_Init(115200,115200);
	log0("Atom PS/2 Keyboard and IO interface V1.0\n");
	log0("2011-05-30 Ramoth Software.\n");
	
	log0("PS/2 keyboard init\n");
	ps2_kbd_init();

	mt_init();

	matrix_init(&mt_output_key,&key_callback);
	
	log0("I/O Init\n");
	InitIO();
	configByte = ReadEEPROM(EE_SYSFLAGS);
	
	log0("MMC Init\n");
	INIT_SPI();
	at_initprocessor();
	
	log0("init done!\n");
	sei();

	flag_init();

	while(1)
	{
		matrix_check_output();
		
		if(LatchInt())
		{
			ClearLatchInt();
			at_process();
		}
	}
	
	return 0;
}
