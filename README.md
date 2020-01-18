# Monkey Island PC Speaker Theme on an Arduino

## Introduction

The beeper sound from DOS game music can be translated into Arduino C code. The code example uses it to play the PC Speaker theme from The Secret of Monkey Island. Please note that this was done in back in 2014, and some of the code needs to be revised to work with the latest Arduino IDE (arrays need to be defined using `const uint16_t melody[] PROGMEM` ).

This was originally done to play a prank on a colleague in the office, by hiding a small Arduino chip (ATmega328P) with a a custom circuit board with a beeper inside his desktop PC.

## How it was done

### The software

The emulator DosBox was used to capture the pc speaker audio to a .wav file. The .wav file was converted to 8 bit signed raw data with Adobe Audition. The raw data file was processed with a Perl script ( `readpcm.pl` ) to turn the pulses into frequency and note duration data. The frequency and duration data was converted into Arduino C code arrays stored in flash. The Arduino tone() function was used to play the contents of the arrays.

### The hardware

My final solution required a custom circuit board to be made, to fit in a slightly smaller space than a normal Arduino UNO circuit board.

The circuit board uses a 20 MHz crystal, rather than the normal 16 MHz one, because my local electronics shop only had a 20 MHz clock crystal in stock, at the time when I was doing this. This meant that the software had to take the 25% frequency increase into account, or the music would play too fast.

The power comes from the +5v and ground wires from a normal USB cable. A capacitor needed to be hooked up across +5v and ground to stop the Arduino chip to crash randomly. Apparently the power from a USB connector is often extremely unstable, and using a capacitor (almost any capacity will probably work) will "filter" the power to make it more reliable.

## Demonstration:

There's a video on YouTube that demonstrates the end result: https://youtu.be/6ORsT4Gs9hA

