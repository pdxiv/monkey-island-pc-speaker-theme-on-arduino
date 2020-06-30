#!/usr/bin/perl
# Read an 8 bit signed pcm file.

use strict;
use warnings;

my $sampleRate        = 44100;
# my $speedMultiplier   = 0.8;     # 20 MHz Arduino Uno
my $speedMultiplier   = 1.0;     # 16 MHz Arduino Uno
my $noteBaseFrequency = 55;

my $fileHandle;
open( $fileHandle, "<", "circus_1.pcm" );
local $/;
my @samples = unpack( "c*", <$fileHandle> );    # Unpack signed 8 bit values
close $fileHandle;

# Round samples to values 0 and 1.
for ( my $t = 0 ; $t < scalar(@samples) ; $t++ ) {
    if ( $samples[$t] < 96 ) {
        $samples[$t] = 0;
    }
    else {
        $samples[$t] = 1;
    }
}

# Put the location of all rising edges in an array.
my $lastValue = 0;
my @positiveEdgeLocations;
$positiveEdgeLocations[0] = 0;
for ( my $t = 0 ; $t < scalar(@samples) ; $t++ ) {
    if ( $lastValue == 0 && $samples[$t] == 1 ) {    # Found positive edge.
        push( @positiveEdgeLocations, $t );
    }
    $lastValue = $samples[$t];
}

# Put all the note of the waveform cycle periods in an array.
my @cycleNoteValue;
for ( my $t = 0 ; $t < ( scalar(@positiveEdgeLocations) - 1 ) ; $t++ ) {
    my $period = $positiveEdgeLocations[ $t + 1 ] - $positiveEdgeLocations[$t];
    my $note = sprintf( "%.f", 12 * log2( ( ( $sampleRate * $speedMultiplier ) / $period ) / $noteBaseFrequency ) );
    push( @cycleNoteValue, $note );
}

# Put frequency (Hz) and duration (ms) values in arrays.
my @noteDurations;
my @noteFrequencies;
my $lastNote            = -999;
my $cyclePerNoteCounter = 0;
my $initialNoteLocation = -999;
for ( my $t = 0 ; $t < scalar(@cycleNoteValue) ; $t++ ) {
    $cyclePerNoteCounter++;

    if ( $cycleNoteValue[$t] != $lastNote ) {
        if ( $cyclePerNoteCounter > 1 ) {
            push( @noteFrequencies, sprintf( "%.f", $noteBaseFrequency * ( 2**( $lastNote / 12 ) ) ) );
        }
        else {
            push( @noteFrequencies, sprintf( "%.f", 0 ) );
        }
        push( @noteDurations, sprintf( "%.f", 1000 * ( $positiveEdgeLocations[$t] - $initialNoteLocation ) / ( $sampleRate * $speedMultiplier ) ) );
        $initialNoteLocation = $positiveEdgeLocations[$t];
        $cyclePerNoteCounter = 0;
    }
    $lastNote = $cycleNoteValue[$t];
}

# Remove initial silence.
while ( $noteFrequencies[0] == 0 ) {
    shift @noteFrequencies;
    shift @noteDurations;
}

print "int numberOfNotes = " . scalar(@noteFrequencies) . ";\n\n";

print "PROGMEM prog_uint16_t melody[] = {\n";
print "  " . join( ", ", @noteFrequencies ) . "\n";
print "};\n\n";

print "PROGMEM prog_uint16_t noteDurations[] = {\n";
print "  " . join( ", ", @noteDurations ) . "\n";
print "};\n\n";

sub log2 {
    my $n = shift;
    return log($n) / log(2);
}
