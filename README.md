# asm6502

This is an attempt at a MOS 6502 assembler. Continuing my trend of living in the past
with Commodore computers and such, this allows me to continue living in the past where
everything was just fun. ;-)

## Concept

This is renewal of the joy I had using Commodore computers in the past. Programs
written with this assembler will run on C64 hardware, emulators, and VICE.

## Implementation

This is done in Java and C, so far, to demonstrate languages and data representation
to my students.

Everything in this design is Java 21 and C23 compatible.

The C version uses [pcre2](https://github.com/PCRE2Project/pcre2) and [PString](https://github.com/jojowil/PString).

At some point the Java one will be revisited. I'm already not liking some of the choices
made during its implementation.

## The Language

This project is based on the [Commodore 64 Assembly Language](https://www.c64-wiki.com/wiki/Assembler) which has a 
specific format where the loading address is the first two byte in little endian format.
There are [tons of examples, forums and further documentation](https://retro-programming.com/hello-world-in-the-c64-machine-code/) all over the Internet.

## Operations

The assembler operates like a heavily watered down version of CA65. There are no
segments or anything overly complex. Some CA65-style verbage is supported (.byte, .word)
while also providing a simplified relocation model when writing program with multiple
blocks.

If you're writing programs with multiple blocks, the assembler will provide a BASIC
preamble and provide relocation for up to 12 blocks. If the program has a block that
starts at \$0801, no relocator is provided. (A future version will provide a relocator
at \$C000.)