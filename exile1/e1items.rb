#!/usr/bin/env ruby

# The items are described in EXILE.EXE beginning at 0xdb3c
# Each item record is 79 bytes
# 0     variety
# 2     level
# 4     bonus
# 6     charges
# 8     type edge/bash/pole or potion/scroll-gem/wand
# 10    name
# 40    fullname
# 71    graphic
# 73    ability
# 75    always zero, maybe used for location
# 77    value

file = File.new(ARGV[0])

# read n items from file and print data in csv format
def read_item file, n
  n.times do
    item = file.read(79)
    variety = item[0..1].unpack("S").first
    level = item[2..3].unpack("S").first
    bonus = item[4..5].unpack("s").first # signed
    charges = item[6..7].unpack("S").first
    type = item[8..9].unpack("S").first # 1,2,3 is potion,scroll/gem,wand
    name = item[10...40].delete("\000")
    fullname = item[40...70].delete("\000")
    identified = item[70].unpack("C").first
    graphic = item[71..72].unpack("S").first
    ability = item[73..74].unpack("S").first
    zero = item[75..76].unpack("S").first
    value = item[77..78].unpack("S").first
    printf "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%s,%s\n",
           variety, level, bonus, charges, type, graphic,
           ability, value, identified, zero, name, fullname
  end
end

# print csv header row
printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n",
           "variety", "level", "bonus", "charges", "type", "graphic",
           "ability", "value", "id?", "zero", "name", "fullname"

# item data are scattered in several places in small chunks
# in the file. There are many duplicates and slight variations
# and identified and unidentified versions of many items.
file.seek(0xdb3c)
read_item file, 17

file.seek(0xe07c)
read_item file, 35

file.seek(0xeb4a)
read_item file, 9

file.seek(0xee12)
read_item file, 9

file.seek(0xf0da)
read_item file, 45

file.seek(0xfebe)
read_item file, 17

file.seek(0x103fe)
read_item file, 43

file.seek(0x32a00)
read_item file, 40

file.seek(0x34342)
read_item file, 6

file.seek(0x3451e)
read_item file, 3

file.seek(0x3460e)
read_item file, 1

file.seek(0x3465e)
read_item file, 4

file.seek(0x347aa)
read_item file, 2

file.seek(0x34852)
read_item file, 1

file.seek(0x348b0)
read_item file, 1

file.seek(0x34900)
read_item file, 6

file.seek(0x34ae6)
read_item file, 1

file.seek(0x34b8e)
read_item file, 3

file.seek(0x34c80)
read_item file, 2

file.seek(0x34d26)
read_item file, 2

file.seek(0x34e2a)
read_item file, 5

file.seek(0x34fb6)
read_item file, 1

file.seek(0x35016)
read_item file, 3

file.seek(0x3511c)
read_item file, 4

file.seek(0x352a8)
read_item file, 1

file.seek(0x352f8)
read_item file, 3

file.seek(0x353e8)
read_item file, 2

file.seek(0x354b8)
read_item file, 1

file.seek(0x35528)
read_item file, 1

file.seek(0x355dc)
read_item file, 3

file.seek(0x356ca)
read_item file, 2

file.seek(0x3576e)
read_item file, 2

file.seek(0x35810)
read_item file, 1

file.seek(0x35860)
read_item file, 1

file.seek(0x358b0)
read_item file, 1

file.seek(0x35900)
read_item file, 3

file.seek(0x359fa)
read_item file, 2

file.seek(0x35a9c)
read_item file, 1

file.seek(0x35b34)
read_item file, 1

file.seek(0x35b84)
read_item file, 1

file.seek(0x35bd4)
read_item file, 4

file.seek(0x35d22)
read_item file, 6

file.seek(0x36e48)
read_item file, 10

file.seek(0x38f3c)
read_item file, 1

file.seek(0x39424)
read_item file, 1

file.seek(0x398e4)
read_item file, 4

file.seek(0x3a2b8)
read_item file, 32

# Spells and Alchemy
# file.seek(0x3748a)
# read_item file, 42
