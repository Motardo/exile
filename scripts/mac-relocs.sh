#!/bin/bash

# The dump file offsets are 4 less than the real offsets in the executable. The
# executable has 4 bytes of SegLoader info at the start. The reloc offsets will
# point to 50, the reloc is at 4c in the dump, and at 50 in the executable

dump=e3code2
a5bytes=e3code2-a5-bytes
segbytes=segbytes
segfmt=segfmt
start=AE2C
segstart=B4C8
a5format="${a5bytes}-format"
dumpformat="${dump}-format"

# Extract A5 Reloc Info from DumpCode file
function extracta5bytes () {
awk '/0000'${start}':/ { p=1; }; { if (p == 1) print; }' "$dump" \
    |cut -c 11-24 \
    |sed 's/ *$//' \
    |sed 's/\([0-9A-F][0-9A-F]\)\([0-9a-f][0-9a-f]\)/\1 \2/gi' \
    |tr ' ' '\n' \
    > "$a5bytes"
}

function format-a5 () {
    $HOME/code/exile/status-icons/mac/printa5.rb < $a5bytes > $a5format
}

function format-dump () {
    sed -n '/^........: /p' $dump > $dumpformat
}

# join -j 1 <( sort "$a5format" ) "$dumpformat" |less
# join -j 1 <( sort "$a5format" ) "$dumpformat" |sort -k 2 |less


function extractSegbytes () {
    awk '/0000'${segstart}':/ { p=1; }; { if (p == 1) print; }' "$dump" \
        |cut -c 11-24 \
        |sed 's/ *$//' \
        |sed 's/\([0-9A-F][0-9A-F]\)\([0-9a-f][0-9a-f]\)/\1 \2/gi' \
        |tr ' ' '\n' \
        |tail -n+4    > "$segbytes"
}

function format-seg () {
    $HOME/code/exile/status-icons/mac/printa5.rb < $segbytes > $segfmt
}

function dataBytes () {
    egrep '^[[:space:]$"]' data0 \
        |tr -d "\t\"$" \
        |sed 's/ *$//' \
        |sed 's/\([^ ][^ ]\)\([^ ][^ ]\)/\1 \2/g' \
        |tr ' ' '\n'
}
