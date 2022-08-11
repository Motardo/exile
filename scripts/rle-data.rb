#!/usr/bin/ruby

# Encode data using the same run-length encoding that the Metrowerks Code
# Warrior compiler uses to encode global initialized data in the DATA0 resource.

# Perform a single pass scan of the input. Each byte belongs to either a
# contiguous sequence of bytes where all adjacent bytes are identical, or a
# contiguous sequence of bytes where no two adjacent bytes are identical.

# Not-same-adjacent sequences are limited in length to 1-128 bytes.
# Same-adjacent sequences are limited in length as follows:
# Same byte   Length
# $00         1-64
# $01-$FE     2-33
# $FF         1-16

# The sequences are encoded as an opcode byte followed by zero or more operand
# bytes like so:

# Opcode     Size of n    Operation
# $80-$FF    (1-128)      copy the next n ($xx - $7F) bytes literally
# $40-$7F    (1-64)       insert n ($xx - $3F) zero bytes
# $20-$3F    (2-33)       repeat the following byte n ($xx - $1E) times
# $10-$1F    (1-16)       insert n ($xx - $0F) $FF bytes
# $01-$0F    ???          ???
# $00        n/a          end of encoded data

# Encode a not-same-adjacent sequence of 1-128 bytes. Output the opcode followed
# by n bytes. `diffs` is the array of bytes to encode.
def flush diffs
  code = 0x80 + diffs.length - 1
  printf "%02X\n", code
  diffs.each do |byte|
    printf "%02X\n", byte
  end
end

# Encode a same-adjacent sequence of n bytes. Output the opcode. Also output one
# operand byte unless the byte is $00 or $FF.
def runof byte, n
  if byte == 0
    printf "%02X\n", (0x40 + n - 1)
  elsif byte == 0xff
    printf "%02X\n", (0x10 + n - 1)
  else
    printf "%02X\n%02X\n", (0x20 + n - 2), byte
  end
end

# Read ascii hex bytes from stdin, one byte per line, and print the encoded
# ascii hex bytes to stdout, one byte per line.
a = readline.hex
diffs = [a]
n = 1
while not $stdin.eof?
  while b = readline.hex and a == b # read same bytes until non-same
    n = n + 1
    # need to limit run lengths
    break if n == 64 and b == 0
    break if n == 16 and b == 0xFF
    break if n == 33 and b != 0 and b != 0xFF
  end
  if n > 1
    diffs.pop # first flush the diffs all except last
    flush diffs
    runof a, n # then output run
    diffs = [b] # reset diffs to just the last byte read
    a = b
    n = 1
  else
    if diffs.length == 128
      flush diffs
      diffs = []
    end
    diffs.append b
    a = b
  end
end
flush diffs
