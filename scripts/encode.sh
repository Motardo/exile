#!/bin/bash
# Calculate the encoded entry in the relocation table from $1 to $2

diff=$(( (0x$1 - 0x$2) / 2 ))
if [[ $diff -le 64 && $diff -gt 0 ]]; then
    printf "%02x\n" $(( 256 - $diff ))
elif [[ $diff -le 0 && $diff -ge -63 ]]; then
    printf "%02x\n" $(( 0x80 - $diff ))
elif [[ $diff -gt 0 ]]; then # two byte back jump
    fivetwelves=$(( ($diff - 1) / 0x100 ))
    remainder=$(( $diff % 0x100 ))
    printf "%02x%02x\n" $(( 0x7f - $fivetwelves )) $(( 256 - $remainder ))
elif [[ $diff -lt 0 ]]; then # two byte forward jump
    diff=$(( $diff * -1 ))
    fivetwelves=$(( $diff / 0x100 ))
    remainder=$(( $diff % 0x100 ))
    printf "%02x%02x\n" $(( 0x40 + $fivetwelves )) $remainder
fi
