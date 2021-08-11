#!/usr/bin/env bash
set -euo pipefail

# Dump the item ability names from EXILE3.EXE
# The names are cstrings from 0x64800 to 0x64f70

dd iflag=skip_bytes,count_bytes skip=$((0x64800)) \
    count=$((0x770)) if=~/dos/c/EXILE3/EXILE3.EXE \
    |tr '\000' '\n' |nl -ba -v0 > e3ability.txt

dd iflag=skip_bytes,count_bytes skip=$((0x656b3)) \
    count=$((0xd2)) if=~/dos/c/EXILE3/EXILE3.EXE \
    |tr '\000' '\n' |cat -n > e3variety.txt

dd iflag=skip_bytes,count_bytes skip=$((0x65df6)) \
    count=$((0x23a)) if=~/dos/c/EXILE3/EXILE3.EXE \
    |tr '\000' '\n' |nl -ba -v0 > e3monst-ability.txt
