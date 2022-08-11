#!/usr/bin/ruby

# Decode the global initialized data in the DATA0 resource produced by the
# Metrowerks Code Warrior compiler.

# The format of the data is a sequence of operations where each operation
# consists of a one byte opcode followed by zero or more bytes of operand. The
# data is terminated with a zero opcode.

# Opcode     Size of n    Operation
# $80-$FF    (1-128)      copy the next n ($xx - $7F) bytes literally
# $40-$7F    (1-64)       insert n ($xx - $3F) zero bytes
# $20-$3F    (2-33)       repeat the following byte n ($xx - $1E) times
# $10-$1F    (1-16)       insert n ($xx - $0F) $FF bytes
# $01-$0F    ???          ???
# $00        n/a          end of encoded data

# Read ascii hex bytes from stdin, one byte per line, as produced by xxd -p -c 1
# for example. Output ascii hex bytes to stdout, one byte per line.

while not $stdin.eof? and byte = readline.hex
  if byte >= 0x80 # n literal bytes follow
    n = (byte - 0x80) + 1
    n.times do
      b = readline.hex
      printf "%02x\n", b
    end
  elsif byte >= 0x40 # n zeros
    n = (byte - 0x40) + 1
    n.times { printf "00\n" }
  elsif byte >= 0x20 # n repetitions of b
    n = (byte - 0x20) + 2
    b = readline.hex
    n.times do
      printf "%02x\n", b
    end
  elsif byte >= 0x10 # n 0xff's
    n = (byte - 0x10) + 1
    n.times {printf "ff\n"}
  elsif byte == 1
    b = readline.hex
    c = readline.hex
    printf "00\n00\n00\n00\nff\nff\n%02x\n%02x\n", b, c
  elsif byte == 2
    b = readline.hex
    c = readline.hex
    d = readline.hex
    printf "00\n00\n00\n00\nff\n%02x\n%02x\n%02x\n", b, c, d
  elsif byte == 3
    b = readline.hex
    c = readline.hex
    d = readline.hex
    printf "a9\nf0\n00\n00\n%02x\n%02x\n00\n%02x\n", b, c, d
  elsif byte == 4
    b = readline.hex
    c = readline.hex
    d = readline.hex
    e = readline.hex
    printf "a9\nf0\n00\n%02x\n%02x\n%02x\n00\n%02x\n", b, c, d, e
  elsif byte != 0x00 # unknown 5..f
    puts "Unknown ".concat(byte.to_s)
    exit
  else # 0x00 end of data
    break
  end
end
