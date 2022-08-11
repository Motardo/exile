# CODE

`draw_pc_effects` CODE:2 $1a04 - $1ff0, in .bin at 0xe4232

```
dumpcode 'Blades of Exile (fat) v1.0.2' -r ' 0x1a00 , 0x1ff0 ' -rt  CODE=2 -a > draw-pc-effects-mb.dump
```
New code is from $1ae6 to $1bd0
New
000e4314: 7C00 3003 C1FC 076A 0640 0060 D046 D046 
000e4324: 45F9 0003 6BFC D5C0 3052 2E08 4A47 677A 
000e4334: 6E1C 0C06 0001 670C 0C06 0003 6706 0C06 
000e4344: 000B 6666 0C47 FFF8 6E0E 3E3C FFF8 0C47 
000e4354: 0008 6D04 3E3C 0008 CFFC 000C 3F04 1F3C 
000e4364: 0001 2F2E FFFC 2F2E FFF8 2F39 0001 1B8A 
000e4374: 3206 E741 43F6 1000 3029 FF6E D047 3F00 
000e4384: 3F29 FF6C 0440 000C 3F00 3F29 FF68 2F39 
000e4394: 0001 1B86 4EB9 0000 3C34 4FEF 001C 066E 
000e43a4: 000D FFFA 066E 000D FFFE BA6E FFFE 6D0A 
000e43b4: 5246 0C06 000E 6D00 FF5A 6000 043C 0000 
000e43c4: 0000 0000 0000 0000 0000 0000 0000 0000
000e43d4: 0000 0000 0000 0000 0000 0000 0000 066E

Original
000e4314: 4a6a 0060 6f3e ba6e fffe 6f38 3f04 1f3c  Jj.`o>.n..o8?..<
000e4324: 0001 2f2e fffc 2f2e fff8 2f39 0001 1b8a  ../.../.../9....
000e4334: 2f2e ff8c 2f2e ff88 2f39 0001 1b86 4eb9  /.../.../9....N.
000e4344: 0000 3c34 066e 000d fffa 066e 000d fffe  ..<4.n.....n....
000e4354: 4fef 001c 3003 c1fc 076a 41f9 0003 6bfc  O...0....jA...k.
000e4364: 4a70 0862 6f38 3f04 1f3c 0001 2f2e fffc  Jp.bo8?..<../...
000e4374: 2f2e fff8 2f39 0001 1b8a 2f2e ff7c 2f2e  /.../9..../..|/.
000e4384: ff78 2f39 0001 1b86 4eb9 0000 3c34 066e  .x/9....N...<4.n
000e4394: 000d fffa 066e 000d fffe 4fef 001c 3003  .....n....O...0.
000e43a4: c1fc 076a 41f9 0003 6bfc 4a70 0862 6c38  ...jA...k.Jp.bl8
000e43b4: 3f04 1f3c 0001 2f2e fffc 2f2e fff8 2f39  ?..<../.../.../9
000e43c4: 0001 1b8a 2f2e ff84 2f2e ff80 2f39 0001  ..../.../.../9..
000e43d4: 1b86 4eb9 0000 3c34 066e 000d fffa 066e  ..N...<4.n.....n


# A5
Reloc info at $bb3c, Num A5 entries $bb3c 0xee36a, Entries start $bb3e 0xee36c
Decode A5 offsets
```
xxd -s 0xee36c -p boeorig.bin |fold -w 2 | ./printa5.rb > a5offsets
```

00001ACE: 0261 1ad0 cf  
00001B00: 0279 1b02 db  
00001B0E: 0295 1b10 db  
00001B30: 0260 1b32 db  
00001B4A: 0278 1b4c db  
00001B58: 0294 1b5a db  
00001B7A: 0259 1b7c db  
00001B94: 0277 1b96 da  
00001BA2: 0293 1ba4 cf  
00001BC4: 0258 1bc6 cf  
00001BE0: 0276 1be2 d0  

```
join -j 1 <(sort a5offsets) <(sed -n '/........:/p' draw-pc-effects-mb.dump | sort)
```
00001BC4: 0258 1bc6 cf <1bc6 cf     41F9 0003 6BFC 'A...k.' LEA $00036BFC,A0 
00001B7A: 0259 1b7c db <  two-byte jump, one less entry   41F9 0003 6BFC 'A...k.' LEA $00036BFC,A0 
00001B30: 0260 1b32 db <1af8 7f99   41F9 0003 6BFC 'A...k.' LEA $00036BFC,A0 
00001ACE: 0261 1ad0 cf <1ad0 ec     45F9 0003 6BFC 'E...k.' LEA $00036BFC,A2 

00001BE0: 0276 1be2 d0 <1be2  d0  2F39 0001 1B8A '/9....' MOVE.L $00011B8A,-(A7) 
00001B94: 0277 1b96 da <1ba0* df  2F39 0001 1B8A '/9....' MOVE.L $00011B8A,-(A7) 
00001B4A: 0278 1b4c db <1b9c* fe  2F39 0001 1B8A '/9....' MOVE.L $00011B8A,-(A7) 
00001B00: 0279 1b02 db <1b42  d3  2F39 0001 1B8A '/9....' MOVE.L $00011B8A,-(A7) 
00001FB2: 0280 1fb4 4259 <1fb4 4239   2F39 0001 1B86 '/9....' MOVE.L $00011B86,-(A7)

00001BA2: 0293 1ba4 cf <1ba4* cf  2F39 0001 1B86 '/9....' MOVE.L $00011B86,-(A7) 
00001B58: 0294 1b5a db <1b98* fa  2F39 0001 1B86 '/9....' MOVE.L $00011B86,-(A7) 
00001B0E: 0295 1b10 db <1b66  e7  2F39 0001 1B86 '/9....' MOVE.L $00011B86,-(A7) 
00001FF6: 0296 1ff8 4274 <1ff8 4249
```
xxd -s 0xee4c2 -l 48 ~/mac/unix/orig/BoEv1.0.2Original.bin
000ee4c2: cfdb dbcf de89 4284 d8d8 d8d8 d8d8 d8d8  ......B.........
000ee4d2: d8db dbd0 dadb db42 59d8 d8d8 d8d8 d8d8  .......BY.......
000ee4e2: d8d8 dbdb dbcf dbdb 4274 407b e9e9 e6d3  ........Bt@{....
```
New A5 is:
000ee4c2: cf7f 99ec de89 4284 d8d8 d8d8 d8d8 d8d8  ......B.........
000ee4d2: d8db dbd0 dffe d342 39d8 d8d8 d8d8 d8d8  .......BY.......
000ee4e2: d8d8 dbdb dbcf fae7 4249 407b e9e9 e6d3  ........Bt@{....

New A5 num entries
000ee36a: 0585 a7f0 bafc 888d fc8c fc8c fc42 3bf9

### Seg

Number of entries at 0xeea64 and entries begin at 0xeea66
```
xxd -s 0xeea66 -p ~/mac/unix/orig/BoEv1.0.2Original.bin |fold -w 2 | ../printa5.rb > segofsets
```
New code is from $1ae6 to $1bb0
```
join -j 1 <(sort segofsets) <(sed -n '/........:/p' draw-pc-effects-mb.dump | sort) |sort -k 2

00001C0A: 0078 1c0c db < 1c0c  db    4EB9 0000 3C34 'N...<4' JSR $00003C34 
00001BA8: 0079 1baa cf < 1bac* d0    4EB9 0000 3C34 'N...<4' JSR $00003C34 
00001B5E: 0080 1b60 db < 1ba8* fe    4EB9 0000 3C34 'N...<4' JSR $00003C34 
00001B14: 0081 1b16 db < 1b6c  e2   4EB9 0000 3C34 'N...<4' JSR $00003C34 
00002114: 0082 2116 4300 < 2116 42d5

xxd -s 0xeeadb -l 16 ~/mac/unix/orig/BoEv1.0.2Original.bin
000eeadb: dbcf dbdb 4300 e9e9 e7d2 e99a 8740 6e9c
```
New Seg is:
000eeadb: dbd0 fee2 42d5 e9e9 e7d2 e99a 8740 6e9c

### Data

Change the source rects in DATA:0
(Since the door-keys patch increases DATA:0 by 4, let's also reduce the size here to keep constant)

Source rects are at 0x140d68

  orig DATA                 orig decoded                new decoded                 new DATA
90 42 01 62 00 4E 01 6E        42 01 62 00 4e 01 6e        42 01 62 00 4e 01 6e     A0 42 01 62 00 4E 01 6E
00 12 00 0F 00 1E 00 1B     00 12 00 0f 00 1e 00 1b     00 12 00 0f 00 1e 00 1b     00 12 00 0F 00 1E 00 1B
00 37 42 94 43 00 0C 00     00 37 00 00 00 43 00 0c     00 9d 00 c0 00 a9 00 cc     00 9D 00 C0 00 A9 00 CC
37 00 0C 00 43 00 18 00     00 37 00 0c 00 43 00 18     00 9d 00 60 00 a9 00 6c     00 9D 00 60 00 A9 00 6C
37 00 18 00 43 00 24 00     00 37 00 18 00 43 00 24     00 cd 00 00 00 d9 00 0c     00 CD 42 94 D9 00 0C 00
43 42 94 4F 00 0C 00 43     00 43 00 00 00 4f 00 0c     00 a9 00 60 00 b5 00 6c     A9 00 60 00 B5 00 6C 00
00 0C 00 4F 00 18 00 43     00 43 00 0c 00 4f 00 18     00 a9 00 c0 00 b5 00 cc     A9 00 C0 00 B5 00 CC 00
00 18 00 4F 00 24 00 4F     00 43 00 18 00 4f 00 24     00 d9 00 00 00 e5 00 0c     D9 42 84 E5 00 0C 00 B5
42 94 5B 00 0C 00 4F 00     00 4f 00 00 00 5b 00 0c     00 b5 00 00 00 c1 00 0c     42 BA C1 00 0C 00 B5 00
0C 00 5B 00 18 00 4F 00     00 4f 00 0c 00 5b 00 18     00 b5 00 60 00 c1 00 6c     60 00 C1 00 6C 00 B5 00
18 00 5B 00 24 00 5B 42     00 4f 00 18 00 5b 00 24     00 b5 00 c0 00 c1 00 cc     C0 00 C1 00 CC 00 CD 00
94 67 00 0C 00 5B 00 0C     00 5b 00 00 00 67 00 0c     00 cd 00 60 00 d9 00 6c     60 00 D9 00 6C 00 CD 00
00 67 00 18 00 5B 00 18     00 5b 00 0c 00 67 00 18     00 cd 00 c0 00 d9 00 cc     C0 00 D9 00 CC 00 C1 00
00 67 00 24 00 67 42 94     00 5b 00 18 00 67 00 24     00 c1 00 60 00 cd 00 6c     60 00 CD 00 6C 00 C1 00
73 00 0C 00 67 00 0C 00     00 67 00 00 00 73 00 0c     00 c1 00 c0 00 cd 00 cc     C0 00 CD 00 CC 00 D9 00
73 00 18 00 67 00 18 00     00 67 00 0c 00 73 00 18     00 d9 00 60 00 e5 00 6c     60 00 E5 00 6C 43 85 01
73 00 24 00 73 42 B0 7F     00 67 00 18 00 73 00 24     00 00 00 00 01 73 00 24     73 00 24 00 73 42 B0 7F
00 0C 00 73 00 0C 00 7F     00 73 00 00 00 7f 00 0c     00 73 00 00 00 7f 00 0c     00 0C 00 73 00 0C 00 7F
00 18 00 73 00 18 00 7F     00 73 00 0c 00 7f 00 18     00 73 00 0c 00 7f 00 18     00 18 00 73 00 18 00 7F
00 24 00 0A 00 14 00 08     00 73 00 18 00 7f 00 24     00 73 00 18 00 7f 00 24     00 24 00 0A 00 14 00 08
00 0A 00 04 00 06 00 0A     00 0a 00 14 00 08 00 0a     00 0a 00 14 00 08 00 0a     00 0A 00 04 00 06 00 0A
00 07 00 0C 00 0F FF F6     00 04 00 06 00 0a 00 07     00 04 00 06 00 0a 00 07     00 07 00 0C 00 0F FF F6
FF F8 FF F8 FF EC FF F8     00 0c 00 0f ff f6 ff f8     00 0c 00 0f ff f6 ff f8     FF F8 FF F8 FF EC FF F8
                            ff f8 ff ec ff f8           ff f8 ff ec ff f8

New source rects
00140d68: A042 0162 004E 016E 0012 000F 001E 001B
00140d78: 009D 00C0 00A9 00CC 009D 0060 00A9 006C
00140d88: 00CD 4294 D900 0C00 A900 6000 B500 6C00
00140d98: A900 C000 B500 CC00 D942 84E5 000C 00B5
00140da8: 42BA C100 0C00 B500 6000 C100 6C00 B500
00140db8: C000 C100 CC00 CD00 6000 D900 6C00 CD00
00140dc8: C000 D900 CC00 C100 6000 CD00 6C00 C100
00140dd8: C000 CD00 CC00 D900 6000 E500 6C43 8501
00140de8: 7300 2400 7342 B07F 000C 0073 000C 007F
00140df8: 0018 0073 0018 007F 0024 000A 0014 0008
00140e08: 000A 0004 0006 000A 0007 000C 000F FFF6
00140e18: fff8 fff8 ffec fff8 4282 0c00 1444 8411

Four bytes shorter
00140de8: 7300 2400 73_46 ac_73 000C 007F

$777b: 4c                 -->    46 81 62 70 43    4 bytes longer door shortcuts
$8538: 42 b0 7f 00 0c 00  -->             46 ac    4 bytes shorter source rects


The separate door-staticons patch integrates the door shortcuts and the source rect changes while
keeping the resource size constant.

DATA:0 changes 0x140030 - 0x140df4

