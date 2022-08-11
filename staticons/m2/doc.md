# CODE

Search the code resources for `draw_pc_effects`, found in CODE:3 $5718 - $5bd0

Dump the routine with dumpcode. Also note the offset of the relocation table
$ca10 (follows the string move_sound)

E2 has 11 statuses (0-10) at adven[pc]+$60 through adven[pc]+$74a  
E2 has 15 different status icons in 15 source_rects in PICT:802 (127 pixels high)a  

The efficient way to add icons is in vertical columns of 96, but this requires
special handling of negative statuses (1 and 3).

We will loop through status 0..10 and if status[i] > 0 then draw from
x = 60 + (12 * i)
y = 12 * status[i]
where status[i] is max 8

If status 1 or 3 is negative, clamp at min -8, and draw from
x = 204 + (12 * (i / 2))
y = 120 + status[i] * 12

New code from $57a8 to $58c0


# Relocation Tables

## A5

The a5 entries begin at 0x59a90, following the `move_sound` string.
```
xxd -s 0x59a90 -p -c 1 e2orig.bin | ../printa5.rb > a5offsets
join -j 1 <(sort a5offsets) <(sed -n '/........:/p' m2-staticons.dump | sort)
```

New code from $57a8 to $58c0

000058F4: 0621 58f6 db   | 58f6  db     41F9 0002 CB92 'A.....' LEA $0002CB92,A0 
00005892: 0622 5894 cf   |              41F9 0002 CB92 'A.....' LEA $0002CB92,A0 
00005848: 0623 584a db   |              41F9 0002 CB92 'A.....' LEA $0002CB92,A0 
000057FE: 0624 5800 db   | 5844  7fa7   41F9 0002 CB92 'A.....' LEA $0002CB92,A0 
000057AE: 0625 57b0 d8   | 57bc  7fbc   41F9 0002 CB92 'A.....' LEA $0002CB92,A0 ; ADVEN
00005B88: 0626 5b8a 41ed | 5b8a  41e7   2F39 0001 CE18 '/9....' MOVE.L $0001CE18,-(A7) 

0000590E: 0634 5910 db   | 5910  db     2F39 0001 CE18 '/9....' MOVE.L $0001CE18,-(A7) 
000058AE: 0635 58b0 d0   | 58ee* ef     2F39 0001 CE18 '/9....' MOVE.L $0001CE18,-(A7) 
00005862: 0636 5864 da   |              2F39 0001 CE18 '/9....' MOVE.L $0001CE18,-(A7) 
00005818: 0637 581a db   | 586e  c0     2F39 0001 CE18 '/9....' MOVE.L $0001CE18,-(A7) 
000057CE: 0638 57d0 db   | 57e6  7fbc   2F39 0001 CE18 '/9....' MOVE.L $0001CE18,-(A7) ; PC_STATS_GWORLD
00005B96: 0639 5b98 41e4 | 5b98  41d9   2F39 0002 1356 '/9...V' MOVE.L $00021356,-(A7) 

0000591C: 0647 591e db   | 591e  db     2F39 0002 1356 '/9...V' MOVE.L $00021356,-(A7) 
000058D2: 0648 58d4 db   | 58ea* e6     2F39 0002 1356 '/9...V' MOVE.L $00021356,-(A7)
00005870: 0649 5872 cf   |              2F39 0002 1356 '/9...V' MOVE.L $00021356,-(A7) 
00005826: 0650 5828 db   | 5892  d4     2F39 0002 1356 '/9...V' MOVE.L $00021356,-(A7) 
000057DC: 0651 57de db   | 580c  7fbd   2F39 0002 1356 '/9...V' MOVE.L $00021356,-(A7) ; MIXED_GWORLD
00005BEA: 0652 5bec 4207 | 5bec  41f0

Orig
00059d62: dbcf dbdb d841 edd8 d8d8 d8d8 c7e9 dbd0
00059d72: dadb db41 e4d8 d8d8 d8d8 d8d8 dbdb cfdb
00059d82: db42 07fc 8cfc 8840 41a2 fc98 f9fd a2fc
New
00059a8e: 06d3 af40 66f1 baf1 4074 f4b8 f4ab 83b8  Number A5 entries
00059d62: db7f a77f bc41 e7d8 d8d8 d8d8 c7e9 dbef
00059d72: c07f bc41 d9d8 d8d8 d8d8 d8d8 dbe6 d47f
00059d82: bd41 f0fc 8cfc 8840 41a2 fc98 f9fd a2fc

## Seg

The seg table begins at 0x5a287
```
xxd -s 0x5a287 -p -c 1 e2orig.bin | ../printa5.rb > segoffsets
join -j 1 <(sort segoffsets) <(sed -n '/........:/p' m2-staticons.dump | sort)
```

000058D8: 0212 58da db   | 58da* db     4EB9 0000 7AD0 'N...z.' JSR $00007AD0 
00005876: 0213 5878 cf   |              4EB9 0000 7AD0 'N...z.' JSR $00007AD0 
0000582C: 0214 582e db   | 5898  df     4EB9 0000 7AD0 'N...z.' JSR $00007AD0 
000057E2: 0215 57e4 db   | 5812  7fbd   4EB9 0000 7AD0 'N...z.' JSR $00007AD0 ; RECT_DRAW_SOME_ITEM
00005C94: 0216 5c96 4259 | 5c96  4242

Orig
0005a3b4: dbdb cfdb db42 59b1 b1be e140 bfe9 e9e7
New
0005a285: 0269 406a f396 4190 9ef5 a38a 9042 377f
0005a3b4: dbdb df7f bd42 42b1 b1be e140 bfe9 e9e7


Confirm all went well
```
xxd -s 0x59a90 -p -c 1 e2patch.bin | ../printa5.rb > pa5offsets
tail a5offsets
tail pa5offsets
```
