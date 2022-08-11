After applying the patch to the bin file, the pict:838 resource must
be copied over, and the preferred size should be increased.
00280bc6: 002a f800 002a f800 0000 0100 0028 0b4e

# CODE

Search the code resources for `draw_pc_effects`, found in CODE:2 $ccc - $fd8

Dump the routine with dumpcode. Also note the offset of the relocation table
$14724 (follows the string display_map)

Exile 1 has no disease, web, sanctuary, dumbfound, martyrs shield, [acid, sleep, paralysis]
Check status 41c e 0 2 4 426  status[0..5]
             pw bc p hs i mr
             
The new code is from $d34 to $e3c


# Relocations

## A5
Reloc info at $14724 (0x25a6ac), Num A5 entries 0x25a6ac, Entries start $0x25a6ae
Decode A5 offsets
```
0025a6ac: 0b66 8d92 fcfc 94fc fc8c 8989 898d fc8c
xxd -s 0x25a6ae -p -c 1 e1orig.bin | ../printa5.rb > a5offsets
join -j 1 <(sort a5offsets) <(sed -n '/........:/p' m1-staticons.dump | sort)
```

00000E82: 0124 0e84 da   | 0e84  da          41F9 0001 9C60  LEA $00019C60,A0 
00000E1E: 0125 0e20 ce   |                  41F9 0001 9C60  LEA $00019C60,A0 
00000DD2: 0126 0dd4 da   |                  41F9 0001 9C60  LEA $00019C60,A0 
00000D86: 0127 0d88 da   | 0dc8  7fa2       41F9 0001 9C60  LEA $00019C60,A0 
00000D3A: 0128 0d3c da   | 0d44  7fbe       41F9 0001 9C60  LEA $00019C60,A0 ; ADVEN 
00000F8E: 0129 0f90 412a | 0f90  4126       2F39 0001 4FBC  MOVE.L $00014FBC,-(A7)

00000E9E: 0132 0ea0 da   | 0ea0  da         2F39 0001 4FBC  MOVE.L $00014FBC,-(A7) 
00000E3C: 0133 0e3e cf   |                  2F39 0001 4FBC  MOVE.L $00014FBC,-(A7) 
00000DEE: 0134 0df0 d9   | 0e50* d8         2F39 0001 4FBC  MOVE.L $00014FBC,-(A7) 
00000DA2: 0135 0da4 da   | 0df0  d0         2F39 0001 4FBC  MOVE.L $00014FBC,-(A7) 
00000D56: 0136 0d58 da   | 0d6c  7fbe       2F39 0001 4FBC  MOVE.L $00014FBC,-(A7) ; PC_STATS_GWORLD 
00000F9C: 0137 0f9e 4123 | 0f9e  4119       2F39 0001 4D5E  MOVE.L $00014D5E,-(A7)

00000E60: 0141 0e62 da   | 0e62  da       2F39 0001 4D5E  MOVE.L $00014D5E,-(A7) 
00000DFC: 0142 0dfe ce   | 0e4c* f5       2F39 0001 4D5E  MOVE.L $00014D5E,-(A7) 
00000DB0: 0143 0db2 da   | 0e10  e2       2F39 0001 4D5E  MOVE.L $00014D5E,-(A7) 
00000D64: 0144 0d66 da   | 0d92  c1       2F39 0001 4D5E  MOVE.L $00014D5E,-(A7) ; MIXED_GWORLD 
00000FE4: 0145 0fe6 4140 | 0fe6  412a       

Orig
0025a738: dace dada da41 2ac5 e9da cfd9 dada 4123
0025a748: d7d7 dada ceda da41 40fc 8cfc b887 99fc
New
0025a738: da7f a27f be41 26c5 e9da d8d0 7fbe 4119
0025a748: d7d7 dada f5e2 c141 2afc 8cfc b887 99fc
New num entries
0025a6ac: 0b63 8d92 fcfc 94fc fc8c 8989 898d fc8c


## Seg
Num entries 0x25b4a9

```
xxd -s 0x25b4ab -p -c 1 e1orig.bin | ../printa5.rb > segoffsets
```

00000E66: 0015 0e68 da   | 0e68  da     4EB9 0000 2400 'N...$.' JSR $00002400 
00000E02: 0016 0e04 ce   | 0e54* f6     4EB9 0000 2400 'N...$.' JSR $00002400 
00000DB6: 0017 0db8 da   | 0e16  e1     4EB9 0000 2400 'N...$.' JSR $00002400 
00000D6A: 0018 0d6c da   | 0d98  c1     4EB9 0000 2400 'N...$.' JSR $00002400 ; RECT_DRAW_ONE_ITEM 
00001070: 0019 1072 4183 | 1072  416d     

Orig
0025b650: dada ceda da41 8340 c3ba 4068 bcb8 4077
New
0025b650: dada f6e1 c141 6d40 c3ba 4068 bcb8 4077




