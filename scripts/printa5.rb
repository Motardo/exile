#!/usr/bin/ruby
# read in the a5 relocation information and extract the offsets

# The code resource has 4 bytes of SegLoader info at the start.
# Use -a switch with DumpObject to account for it.

# Dump each entry as address: i offset byte
# address is offset - 2

offset = 0
n = 1
while not $stdin.eof? and a = readline and a.hex != 0
  b = "-1"
  byte = a.hex
  if byte >= 0xc0 # go back 2..128
    offset = offset - (2 * (256 - byte))
  elsif byte >= 0x80 # go forward 0..126
    offset = offset + (2 * (byte - 0x80))
  elsif byte >= 0x70 # treat next byte as back jump even though it's less than c0
    b = readline
    offset = offset - (2 * (256 - b.hex))
    offset = offset - (0x200 * (0x7f - byte))
  elsif byte >= 0x40 # go forward two bytes - 0x4000
    b = readline
    word = (256 * (byte - 0x40)) + b.hex
    offset = offset + (2 * word)
  end
  if b.hex >= 0
    printf "%08X: %04d %04x %02x%02x\n", offset - 2, n, offset, byte, b.hex
  else
  printf "%08X: %04d %04x %02x  \n", offset - 2, n, offset, byte
  end
  n = n + 1
end
