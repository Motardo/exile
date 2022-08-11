# PC Status Icons Patch

Use up to eight different icons to indicate statuses depending on the
status level. New icons added to mixed.bmp, executable is patched in three places:
1. the code that draws the status icons
2. the relocation table entries for said code
3. the initialized data segment for the icon rects

## patch install (Windows versions)

1. replace the original mixed.bmp with the new version with new icons appended
to the bottom.
2. apply the patch file to the original executable

Drawing the PC status area
  `put_pc_screen` calls `draw_pc_effects`
`draw_pc_effects` iterates pc's statuses and draws appropriate icons.

Add new icons to `MIXED.BMP` (Windows version)


#### Code: Blades 0xf2bed, Exile3 0x1062ee, Exile2 0x6e711, Exile 0x4bf1f

routine is in EXILE3.EXE at 0x1062ee until 0x1069a5, length 0x6b7 (1719) bytes
Seg# 27: 0x00103a00  0x5ab5
```
ndisasm -e 0x103a00 -k 0,0x28ee EXILE3.EXE.orig |less  -- until 0x2fa4 (1719 bytes)
ndisasm -e 0x103a00 -k 0,0x28ee ~/dos/c/EXILE3/EXILE3.EXE |head -562 >pc-effects-w3.lst
```

Exile 3 Status Icons
---
0 poison
1 very poisoned
2 bless  24,54 -> 24,352
3 curse
4 pweapon
5 invulnerable
6 haste
7 normal speed
8 slow
9 magic res
10 web
11 disease
12 sanctuary
13 dumfound
14 martys shield
15 sleep
16 paralyzed?
17 acid

Redundancy in `pc_effects` status[5] through status[13], same 86 bytes 9 times
only stepping one instruction by 8, and another by 2

W3 Status and New Icon Rects
---
| status                      | x,y     | top left bottom right |
| :-------------------------- | :------ | :-------------------- |
| 0 pweapon                   | 192,296 | 2801 c000 3401 cc00   |
| 1 bless/curse               | 96,296  | 2801 6000 3401 6c00   |
| 2 poison (4+ very poisoned) | 288,296 | 2801 2001 3401 2c01   |
| 3 haste/slow                | 96,308  | 3401 6000 4001 6c00   |
| 4 invulnerable              | 192,308 | 3401 c000 4001 cc00   |
| 5 magic res                 | 288,308 | 3401 2001 4001 2c01   |
| 6 web                       | 0,320   | 4001 0000 4c01 0c00   |
| 7 disease                   | 96,320  | 4001 6000 4c01 6c00   |
| 8 sanctuary                 | 192,320 | 4001 c000 4c01 cc00   |
| 9 dumfound                  | 288,320 | 4001 2001 4c01 2c01   |
| 10 martys shield            | 192,344 | 5801 c000 6401 cc00   |
| 11 sleep                    | 96,332  | 4c01 6000 5801 6c00   |
| 12 paralyzed                | 192,332 | 4c01 c000 5801 cc00   |
| 13 acid                     | 288,332 | 4c01 2001 5801 2c01   |


```bash
# convert x,y to rects
~> xsel |tr , ' ' |awk '{printf "%04x %04x %04x %04x\n", $2, $1, $2+12, $1+12}'
0128 00c0 0134 00cc
0128 0060 0134 006c
0128 0120 0134 012c
0134 0060 0140 006c
0134 00c0 0140 00cc
0134 0120 0140 012c
0140 0000 014c 000c
0140 0060 014c 006c
0140 00c0 014c 00cc
0140 0120 014c 012c
0158 00c0 0164 00cc
014c 0060 0158 006c
014c 00c0 0158 00cc
014c 0120 0158 012c

# swap bytes
~/dos> xsel |sed 's/\([^ ][^ ]\)\([^ ][^ ]\)/\2\1/g'
2801 c000 3401 cc00
2801 6000 3401 6c00
2801 2001 3401 2c01
3401 6000 4001 6c00
3401 c000 4001 cc00
3401 2001 4001 2c01
4001 0000 4c01 0c00
4001 6000 4c01 6c00
4001 c000 4c01 cc00
4001 2001 4c01 2c01
5801 c000 6401 cc00
4c01 6000 5801 6c00
4c01 c000 5801 cc00
4c01 2001 5801 2c01

# Patch icon rects
0005f6a0: 2801 c000 3401 cc00 2801 6000 3401 6c00
0005f6b0: 2801 2001 3401 2c01 3401 6000 4001 6c00
0005f6c0: 3401 c000 4001 cc00 3401 2001 4001 2c01
0005f6d0: 4001 0000 4c01 0c00 4001 6000 4c01 6c00
0005f6e0: 4001 c000 4c01 cc00 4001 2001 4c01 2c01
0005f6f0: 5801 c000 6401 cc00 4c01 6000 5801 6c00
0005f700: 4c01 c000 5801 cc00 4c01 2001 5801 2c01
```

Local Vars
----------------

| [bp-0xae] | source_rects     | 0x90 | 18*8 byte rects |
| [bp-0x1e] | dest_bmp         |      |                 |
| [bp-0x1c] | mode             | 2    | = 1 (trans)     |
| [bp-0x1a] | i                | 2    |                 |
| [bp-0x18] | name_width       | 2    |                 |
| [bp-0x16] | right_limit      | 2    | = 250           |
| [bp-0x13] | on_dialog        | 1    | = FALSE         |
| [bp-0x12] | dlog_dest_rect   | 8    |                 |
| [bp-0x0a] | dest_rect        | 8    |                 |
| [bp-0x08] | dest_rect.top    |      |                 |
| [bp-0x06] | dest_rect.right  |      |                 |
| [bp-0x04] | dest_rect.bottom |      |                 |
| di        | dest             |      | = 0 (in gworld) |
| [bp+0x06] | pc               |      | first param     |
| [bp+0x08] | dest_dc          |      | second param    |

## Source Rects

source_rects in file at 0x5f6a0
Seg# 48: 0x0005c000  0x6f64  0x0d51

```
~/code/exile/status-icons> xxd -s 0x5f6a0 -l 0x90 $file
0005f6a0: 3700 0000 4300 0c00 3700 0c00 4300 1800  7...C...7...C...
0005f6b0: 3700 1800 4300 2400 4300 0000 4f00 0c00  7...C.$.C...O...
0005f6c0: 4300 0c00 4f00 1800 4300 1800 4f00 2400  C...O...C...O.$.
0005f6d0: 4f00 0000 5b00 0c00 4f00 0c00 5b00 1800  O...[...O...[...
0005f6e0: 4f00 1800 5b00 2400 5b00 0000 6700 0c00  O...[.$.[...g...
0005f6f0: 5b00 0c00 6700 1800 5b00 1800 6700 2400  [...g...[...g.$.
0005f700: 6700 0000 7300 0c00 6700 0c00 7300 1800  g...s...g...s...
0005f710: 6700 1800 7300 2400 7300 0000 7f00 0c00  g...s.$.s.......
0005f720: 7300 0c00 7f00 1800 7300 1800 7f00 2400  s.......s.....$.
```

Point the first 14 rects to status[i] icons where status is zero and not shown.
The actual icons are shifted left and right from the source rect according to the
value of the status.

```
0005f6a0: 2801 c000 3401 cc00 2801 6000 3401 6c00
0005f6b0: 2801 2001 3401 2c01 3401 6000 4001 6c00
0005f6c0: 3401 c000 4001 cc00 3401 2001 4001 2c01
0005f6d0: 4001 0000 4c01 0c00 4001 6000 4c01 6c00
0005f6e0: 4001 c000 4c01 cc00 4001 2001 4c01 2c01
0005f6f0: 5801 c000 6401 cc00 4c01 6000 5801 6c00
0005f700: 4c01 c000 5801 cc00 4c01 2001 5801 2c01
```

## Icons

new icons in mixed.bmp add space to bottom of image

patch 164 bytes from 2a45 - 2ae7
1200+ bytes from 2ae7 - 2fa4 not used
beginning from 28ee - 2a45 unchanged

## Changed Code

Loop through i = 0 to 13 statuses
if status is zero, continue
else if status is negative and i != 1, 3, or 11 // curse, slow, neg-sleep
  continue
else
  shift_value = (status[i] clamped to +- 8) * 12
  draw source_rect[i] shifted right by shift_value

patch code at 103a00 + 2a45 = 106445
```
~/code/exile/status-icons> xxd -o 0x106445 new-pc-effects-w3
00106445: e9ac 00c7 46e6 0000 89f3 69db 2207 8b46  ....F.....i."..F
00106455: e601 c301 c3b8 0000 8ec0 268b 8786 8583  ..........&.....
00106465: f800 747f 7f14 8b5e e683 fb01 7414 83fb  ..t....^....t...
00106475: 0374 0f83 fb0b 740a eb69 83f8 097c 03b8  .t....t..i...|..
00106485: 0800 83f8 f77f 03b8 f8ff 6bc0 0c89 46e8  ..........k...F.
00106495: 57ff 76e4 8d46 f68c d2b9 0800 9aff ff00  W.v..F..........
001064a5: 00ff 76e2 8b5e e6c1 e303 8d96 52ff 01d3  ..v..^......R...
001064b5: ff77 068b 4704 0346 e850 ff77 0283 e80c  .w..G..F.P.w....
001064c5: 50b8 0000 8ec0 26ff 360e 509a ffff 0000  P.....&.6.P.....
001064d5: 83c4 1883 46f6 0d83 46fa 0d8b 46fa 3b46  ....F...F...F.;F
001064e5: ea7d 0cff 46e6 837e e60e 7d03 e959 ff5f  .}..F..~..}..Y._
001064f5: 5e8d 66fe 1f5d 4dcb 0000 0000 0000 0000  ^.f..]M.........
00106505: 0000 0000 0000 0000 00                   .........
```

## Relocs

```
~/code/exile/status-icons> relocsBetween 27 0x2a45 0x2b0e
0010a3b7: 0402 2a4f 002c 8526  adven
0010a3af: 0003 2a70 0001 10f6  memcpy
0010a3a7: 0003 2a81 0001 10f6  memcpy
0010a39f: 0402 2a86 0030 500e  mixed_gworld
0010a397: 0003 2a90 000c 1015  rect_draw_some_item
0010a38f: 0402 2aa6 002c 8526  ...*,.&.
0010a387: 0003 2abf 0001 10f6  ...*....
0010a37f: 0003 2ad0 0001 10f6  ...*....
0010a377: 0402 2ad5 0030 500e  ...*0..P
0010a36f: 0003 2adf 000c 1015  ...*....
0010a367: 0402 2af5 002c 8526  ...*,.&.
0010a35f: 0003 2b0e 0001 10f6  ...+....
```

Will alter the first 4 entries for our patch and point the next 7 entries past the end
of our patch from 2b00 - 2b0e
Will need to pad patch out with zeros to 2b0e to accept dummy relocs

```
0010a3b7: 0402 2a5b 002c 8526  adven
0010a3af: 0003 2aa2 0001 10f6  memcpy
0010a3a7: 0402 2ac7 0030 500e  mixed_gworld
0010a39f: 0003 2ad1 000c 1015  rect_draw_some_item
0010a397: 0402 2b00 002c 8526  adven
0010a38f: 0402 2b02 002c 8526  adven
0010a387: 0402 2b04 002c 8526  adven
0010a37f: 0402 2b06 002c 8526  adven
0010a377: 0402 2b08 002c 8526  adven
0010a36f: 0402 2b0a 002c 8526  adven
0010a367: 0402 2b0c 002c 8526  adven

~/code/exile/status-icons> xsel | sort | cut -c 11- | swapEndian 
0204 0c2b 2c00 2685
0204 0a2b 2c00 2685
0204 082b 2c00 2685
0204 062b 2c00 2685
0204 042b 2c00 2685
0204 022b 2c00 2685
0204 002b 2c00 2685
0300 d12a 0c00 1510
0204 c72a 3000 0e50
0300 a22a 0100 f610
0204 5b2a 2c00 2685

# The relocs patch
0010a367: 0204 0c2b 2c00 2685 0204 0a2b 2c00 2685
0010a377: 0204 082b 2c00 2685 0204 062b 2c00 2685
0010a387: 0204 042b 2c00 2685 0204 022b 2c00 2685
0010a397: 0204 002b 2c00 2685 0300 d12a 0c00 1510
0010a3a7: 0204 c72a 3000 0e50 0300 a22a 0100 f610
0010a3b7: 0204 5b2a 2c00 2685
```

# Blades

## Code

0xf2bed is in seg 21, offset 23ed

```
Seg# 21: 0x000f0800  0x52a9  0x1d10
ndisasm -e 0xf0800  -k 0,0x23ed BLADEXIL/BLADES.EXE |tail -n+2 |head -560 >blades-orig.lst

~/code/exile/status-icons> xxd -o 0xf2d43 wb-staticons
000f2d43: c746 e600 00eb 118b 46fa 3b46 ea7d eeff
000f2d53: 46e6 837e e60e 7de5 89f3 69db 6a07 8b46
000f2d63: e601 c301 c3b8 0000 8ec0 268b 87b4 b383
000f2d73: f800 74d3 7f14 8b5e e683 fb01 7414 83fb
000f2d83: 0374 0f83 fb0b 740a ebbd 83f8 097c 03b8
000f2d93: 0800 83f8 f77f 03b8 f8ff 6bc0 0c89 46e8
000f2da3: 57ff 76e4 8d46 f68c d2b9 0800 9aff ff00
000f2db3: 00ff 76e2 8b5e e6c1 e303 8d96 52ff 01d3
000f2dc3: ff77 068b 4704 0346 e850 ff77 0283 e80c
000f2dd3: 50b8 0000 8ec0 26ff 364c 7c9a ffff 0000
000f2de3: 83c4 1883 46f6 0d83 46fa 0de9 59ff 0000
000f2df3: 0000 0000 0000 0000 0000 0000 0000 0000
```

## Relocs

```
~/code/exile/status-icons> relocsBetween 21 0x2540 0x261a
000f69bb: 0402 254a 0023 b354  ADVEN
000f69b3: 0003 256b 0001 10ca  MEMCPY
000f69ab: 0003 257c 0001 10ca  ..|%....
000f69a3: 0402 2581 002b 7c4c  MIXED
000f699b: 0003 258b 000a 0cb5  RECT_DRAW_SOME_ITEM
000f6993: 0402 25a1 0023 b354  ...%#.T.
000f698b: 0003 25ba 0001 10ca  ...%....
000f6983: 0003 25cb 0001 10ca  ...%....
000f697b: 0402 25d0 002b 7c4c  ...%+.L|
000f6973: 0003 25da 000a 0cb5  ...%....
000f696b: 0402 25f0 0023 b354  ...%#.T.
000f6963: 0003 2609 0001 10ca  ...&....
000f695b: 0003 261a 0001 10ca  ...&....


~/code/exile/status-icons> xsel |sort |cut -c 11- |swapEndian 
000f6963: 0204 0e26 2300 54b3 0204 0c26 2300 54b3
000f6973: 0204 0a26 2300 54b3 0204 0826 2300 54b3
000f6983: 0204 0626 2300 54b3 0204 0426 2300 54b3
000f6993: 0204 0226 2300 54b3 0204 0026 2300 54b3
000f69a3: 0300 cc25 0a00 b50c 0204 c225 2b00 4c7c
000f69b3: 0300 9d25 0100 ca10 0204 5625 2300 54b3
```

## Source Rects

| status                      | x,y     | top left bottom right |
| :-------------------------- | :------ | :-------------------- |
| 0 pweapon                   | 192,296 | 2801 c000 3401 cc00   |
| 1 bless/curse               | 96,296  | 2801 6000 3401 6c00   |
| 2 poison (4+ very poisoned) | 0,332   | 4c01 0000 5801 0c00   |
| 3 haste/slow                | 96,308  | 3401 6000 4001 6c00   |
| 4 invulnerable              | 192,308 | 3401 c000 4001 cc00   |
| 5 magic res                 | 0,344   | 5801 0000 6401 0c00   |
| 6 web                       | 0,356   | 6401 0000 7001 0c00   |
| 7 disease                   | 96,356  | 6401 6000 7001 6c00   |
| 8 sanctuary                 | 192,320 | 4001 c000 4c01 cc00   |
| 9 dumfound                  | 96,332  | 4c01 6000 5801 6c00   |
| 10 martys shield            | 192,344 | 5801 c000 6401 cc00   |
| 11 sleep                    | 96,320  | 4001 6000 4c01 6c00   |
| 12 paralyzed                | 192,332 | 4c01 c000 5801 cc00   |
| 13 acid                     | 96,344  | 5801 6000 6401 6c00   |


```
            b/c 96 296  pw  192 296
            h/s 96 308  inv 192 308
            sl  96 320  san 192 320
poi 0  332  dm  96 332  par 192 332
mr  0  344  ac  96 344  msh 192 344
web 0  356  dis 96 356

~/dos/c/orig> xxd -s 0x77548 -l 144 BLADEXIL/BLADES.EXE 
00077548: 3700 0000 4300 0c00 3700 0c00 4300 1800  7...C...7...C...
00077558: 3700 1800 4300 2400 4300 0000 4f00 0c00  7...C.$.C...O...
00077568: 4300 0c00 4f00 1800 4300 1800 4f00 2400  C...O...C...O.$.
00077578: 4f00 0000 5b00 0c00 4f00 0c00 5b00 1800  O...[...O...[...
00077588: 4f00 1800 5b00 2400 5b00 0000 6700 0c00  O...[.$.[...g...
00077598: 5b00 0c00 6700 1800 5b00 1800 6700 2400  [...g...[...g.$.
000775a8: 6700 0000 7300 0c00 6700 0c00 7300 1800  g...s...g...s...
000775b8: 6700 1800 7300 2400 7300 0000 7f00 0c00  g...s.$.s.......
000775c8: 7300 0c00 7f00 1800 7300 1800 7f00 2400  s.......s.....$.

becomes
00077548: 2801 c000 3401 cc00 2801 6000 3401 6c00
00077558: 4c01 0000 5801 0c00 3401 6000 4001 6c00
00077568: 3401 c000 4001 cc00 5801 0000 6401 0c00
00077578: 6401 0000 7001 0c00 6401 6000 7001 6c00
00077588: 4001 c000 4c01 cc00 4c01 6000 5801 6c00
00077598: 5801 c000 6401 cc00 4001 6000 4c01 6c00
000775a8: 4c01 c000 5801 cc00 5801 6000 6401 6c00
```

# Exile 2 0x63711

```
Seg#  5: 0x0006b200  0x5f31  0x1d10
0x6e711 printf "%x\n" $(( 0x6e711 - 0x6b200 ))
printf "%x\n" $(( 0x6e711 - 0x6b200 )) = 0x3511

ndisasm -e 0x6b200 -k 0,0x3511 $file |tail -n+2 |head -438 >e2-staticons.lst
ends at 3a33

~/code/exile/status-icons> relocsBetween 5 0x3511 0x3700
00071a23: 0402 35ef 002c 7f70  ...5,.p.
00071a1b: 0402 3601 0028 94b2  ADVEN
00071a13: 0003 3621 0001 10ca  MEMCPY
00071a0b: 0003 3631 0001 10ca  MEMCPY
00071a03: 0402 3636 002c 3cc4  MIXED
000719fb: 0003 3640 0003 08fa  RECT_DRAW
000719f3: 0402 3656 0028 94b2  ..V6(...
000719eb: 0003 366e 0001 10ca  ..n6....
000719e3: 0003 367f 0001 10ca  ...6....
000719db: 0402 3684 002c 3cc4  ...6,..<
000719d3: 0003 368e 0003 08fa  ...6....
000719cb: 0402 36a4 0028 94b2  ...6(...
000719c3: 0003 36bc 0001 10ca  ...6....
000719bb: 0003 36cc 0001 10ca  ...6....

00071a1b: 0402 3626 0028 94b2  ADVEN
00071a13: 0003 3667 0001 10ca  MEMCPY
00071a0b: 0402 368c 002c 3cc4  MIXED
00071a03: 0003 3696 0003 08fa  RECT_DRAW
000719fb: 0402 36aa 0028 94b2  ADVEN
000719f3: 0402 36ac 0028 94b2  ADVEN
000719eb: 0402 36ae 0028 94b2  ADVEN
000719e3: 0402 36b0 0028 94b2  ADVEN
000719db: 0402 36b2 0028 94b2  ADVEN
000719d3: 0402 36b4 0028 94b2  ADVEN
000719cb: 0402 36b6 0028 94b2  ADVEN
000719c3: 0003 36bc 0001 10ca  MEMCPY

000719c3: 0300 bc36 0100 ca10 0204 b636 2800 b294
000719d3: 0204 b436 2800 b294 0204 b236 2800 b294
000719e3: 0204 b036 2800 b294 0204 ae36 2800 b294
000719f3: 0204 ac36 2800 b294 0204 aa36 2800 b294
00071a03: 0300 9636 0300 fa08 0204 8c36 2c00 c43c
00071a13: 0300 6736 0100 ca10 0204 2636 2800 b294
```
## W2 Source Rects

The rects will be offset in the initialization code, so we will
change the code to skip the translation.

| status                      | x,y     | top left bottom right |
| :-------------------------- | :------ | :-------------------- |
| 0 pweapon                   | 192,327 | 2801 c000 3401 cc00   |
| 1 bless/curse               | 96,327  | 2801 6000 3401 6c00   |
| 2 poison (4+ very poisoned) | 0,363   | 4c01 0000 5801 0c00   |
| 3 haste/slow                | 96,339  | 3401 6000 4001 6c00   |
| 4 invulnerable              | 192,339 | 3401 c000 4001 cc00   |
| 5 magic res                 | 96,363  | 5801 0000 6401 0c00   |
| 6 web                       | 0,351   | 6401 0000 7001 0c00   |
| 7 disease                   | 96,351  | 6401 6000 7001 6c00   |
| 8 sanctuary                 | 192,351 | 4001 c000 4c01 cc00   |
| 9 dumfound                  | 192,375 | 4c01 6000 5801 6c00   |
| 10 martys shield            | 192,363 | 5801 c000 6401 cc00   |

```
# The rects are translated in mixed.bmp
~/code/exile/status-icons> xxd -s 0x4f982 -l 0x78 $file
0004f982: 3700 0000 4300 0c00 3700 0c00 4300 1800  7...C...7...C...
0004f992: 3700 1800 4300 2400 4300 0000 4f00 0c00  7...C.$.C...O...
0004f9a2: 4300 0c00 4f00 1800 4300 1800 4f00 2400  C...O...C...O.$.
0004f9b2: 4f00 0000 5b00 0c00 4f00 0c00 5b00 1800  O...[...O...[...
0004f9c2: 4f00 1800 5b00 2400 5b00 0000 6700 0c00  O...[.$.[...g...
0004f9d2: 5b00 0c00 6700 1800 5b00 1800 6700 2400  [...g...[...g.$.
0004f9e2: 6700 0000 7300 0c00 6700 0c00 7300 1800  g...s...g...s...
0004f9f2: 6700 1800 7300 2400                      g...s.$.

            b/c 96 327  pw  192 327
            h/s 96 339  inv 192 339
web 0  351  dis 96 351  san 192 351
poi 0  363  mgr 96 363  msh 192 363
                        dum 192 375

# Convert x,y to patch
xsel |tr , ' ' |awk '{printf "%04x %04x %04x %04x\n", $2, $1, $2+12, $1+12}'
xsel |sed 's/\([^ ][^ ]\)\([^ ][^ ]\)/\2\1/g'
xsel |tr '\n' ' ' |fold -w 40 ; echo

# unaltered
0004f982: 4701 c000 5301 cc00 4701 6000 5301 6c00 
0004f992: 6b01 0000 7701 0c00 5301 6000 5f01 6c00 
0004f9a2: 5301 c000 5f01 cc00 6b01 6000 7701 6c00 
0004f9b2: 5f01 0000 6b01 0c00 5f01 6000 6b01 6c00 
0004f9c2: 5f01 c000 6b01 cc00 7701 c000 8301 cc00 
0004f9d2: 6b01 c000 7701 cc00 5b00 1800 6700 2400 
# transposed
0004f982: c000 4701 cc00 5301 6000 4701 6c00 5301
0004f992: 0000 5001 0c00 5c01 6000 5301 6c00 5f01
0004f9a2: c000 5301 cc00 5f01 6000 5001 6c00 5c01
0004f9b2: 0000 5f01 0c00 6b01 6000 5f01 6c00 6b01
0004f9c2: c000 5f01 cc00 6b01 c000 7701 cc00 8301
0004f9d2: c000 6b01 cc00 7701 1800 5b00 2400 6700
```

## Exile 1

need to patch offset rect call also

```
Seg#  6: 0x0004a200  0x3d63  0x1d10
Seg#  6: 0x0004a200  0x3d63  0x1d10, 0x4bf1f is offset 1d1f
ndisasm -e 0x4a200 -k 0,0x1d1f ~/dos/EXILE.EXE |less
```


00001E06  2683BF100400      cmp word [es:bx+0x410],byte +0x0 ; status[0]
00001E31  8D4692            lea ax,[bp-0x6e] ; source_rects[4] PW
00001E63  2683BF120400      cmp word [es:bx+0x412],byte +0x0 ; status[1]
00001E86  8D4682            lea ax,[bp-0x7e] ; source_rect[2] bless
00001EB8  2683BF120400      cmp word [es:bx+0x412],byte +0x0 ; status[1]
00001EDB  8D468A            lea ax,[bp-0x76] ; source_rects[3] curse
00001F0D  2683BF140400      cmp word [es:bx+0x414],byte +0x0 ; status[2]
00001F4F  8D9E72FF          lea bx,[bp-0x8e] ; source_rects[0] light poison
[bp-0x86] major poison
00001F82  2683BF180400      cmp word [es:bx+0x418],byte +0x0 ; status[4]
00001FA5  8D469A            lea ax,[bp-0x66] ; source_rects[5] ; invuln
00001FD7  2683BF160400      cmp word [es:bx+0x416],byte +0x0 ; status[3]
00001FFA  8D46A2            lea ax,[bp-0x5e] ; source_rects[6] haste
0000203C  8D9E72FF          lea bx,[bp-0x8e] ; source_rects[0 + 7 or 8] normal/haste
0000206F  2683BF1A0400      cmp word [es:bx+0x41a],byte +0x0 ; status[5]
0000209A  8D46BA            lea ax,[bp-0x46] ; source_rects[9] magic-res

### Code

```
~/code/exile/status-icons> xxd -o 0x4bffb e1-new-staticons
0004bffb: e9c3 0231 ffeb 0e47 83ff 057f f38b 46fa  ...1...G......F.
0004c00b: 3b46 f27d eb89 f369 db84 0489 f801 c301  ;F.}...i........
0004c01b: c3b8 0000 8ec0 268b 8710 0483 f800 74d7  ......&.......t.
0004c02b: 7f0e 89fb 83fb 0174 0f83 fb03 740a ebc7  .......t....t...
0004c03b: 83f8 097c 03b8 0800 83f8 f77f 03b8 f8ff  ...|............
0004c04b: 6bc0 0c89 46ca 6a01 6a01 8d46 f68c d2b9  k...F.j.j..F....
0004c05b: 0800 9aff ff00 00b8 0000 8ec0 26ff 3648  ............&.6H
0004c06b: 9489 fbc1 e303 8d96 72ff 01d3 ff77 068b  ........r....w..
0004c07b: 4704 0346 ca50 ff77 0283 e80c 50b8 0000  G..F.P.w....P...
0004c08b: 8ec0 26ff 3648 949a ffff 0000 83c4 1883  ..&.6H..........
0004c09b: 46f6 0d83 46fa 0de9 5dff 0000 0000 0000  F...F...].......
0004c0ab: 0000 0000 0000 0000
```

### Relocs

```
~/code/exile/status-icons> relocsBetween 6 0x1df0 0x1e90
0004e45d: 0103 1df7 0005 004d  ......M.
0004e455: 0402 1e02 0018 0000  ADVEN
0004e44d: 0003 1e23 0001 10ca  MEMCPY
0004e445: 0402 1e28 001c 9448  DEST_BMP
0004e43d: 0003 1e3a 0001 10ca  MEMCPY
0004e435: 0402 1e3f 001c 9448  MIXED_GWORLD
0004e42d: 0003 1e49 0010 0821  RECT_DRAW_SOME_ITEM
0004e425: 0402 1e5f 0018 0000  .._.....
0004e41d: 0003 1e78 0001 10ca  ..x.....
0004e415: 0402 1e7d 001c 9448  ..}...H.
0004e40d: 0003 1e8f 0001 10ca  ........
0004e405: 0402 1e94 001c 9448  ......H.
0004e3fd: 0003 1e9e 0010 0821  ......!.
0004e3f5: 0402 1eb4 0018 0000  ........

becomes
0004e455: 0402 1e1a 0018 0000  ADVEN
0004e44d: 0003 1e5e 0001 10ca  MEMCPY
0004e445: 0402 1e63 001c 9448  DEST_BMP
0004e43d: 0402 1e89 001c 9448  MIXED_GWORLD
0004e435: 0003 1e93 0010 0821  RECT_DRAW_SOME_ITEM
0004e42d: 0402 1ea5 0018 0000  ADVEN
0004e425: 0402 1ea7 0018 0000  ADVEN
0004e41d: 0402 1ea9 0018 0000  ADVEN
0004e415: 0402 1eab 0018 0000  ADVEN
0004e40d: 0402 1ead 0018 0000  ADVEN
0004e405: 0402 1eaf 0018 0000  ADVEN
0004e3fd: 0402 1eb1 0018 0000  ADVEN
```

### Source Rects

```
~/code/exile/status-icons> xxd -s 0x34154 -l 120 $file
00034154: 0000 0000 0c00 0c00 0000 0c00 0c00 1800  ................
00034164: 0000 1800 0c00 2400 0c00 0000 1800 0c00  ......$.........
00034174: 0c00 0c00 1800 1800 0c00 1800 1800 2400  ..............$.
00034184: 1800 0000 2400 0c00 1800 0c00 2400 1800  ....$.......$...
00034194: 1800 1800 2400 2400 2400 0000 3000 0c00  ....$.$.$...0...
000341a4: 2400 0c00 3000 1800 2400 1800 3000 2400  $...0...$...0.$.
000341b4: 3000 0000 3c00 0c00 3000 0c00 3c00 1800  0...<...0...<...
000341c4: 3000 1800 3c00 2400

0 pw    0  253
1 b/c  96  229
2 poi  96  253
3 h/s  96  241
4 inv   0  265
5 magr 96  265
          t    l    b    r    t    l    b    r
00034154: fd00 0000 0901 0c00 e500 6000 f100 6c00  ................
00034164: fd00 6000 0901 6c00 f100 6000 fd00 6c00  ......$.........
00034174: 0901 0000 1501 0c00 0901 6000 1501 6c00  ..............$.
```


# Macintosh

## Blades


## Exile 3 fat v1.0.3

- change the `draw_pc_effects` routine: code2 1d12 - 1dc2
- change the source rects: compressed data0 f8a0 - f92d
- change the a5 and segment relocs: compressed code2
- change the pict resource: 'Exile 3 Graphics' pict:903



CODE 2 0x1c34
source_rect[0] is -0x98(a6)
initialized data loaded from 0x1540c
DATA0 0xf8a0 - 0xf92d: 3742 9443 ...

A5 offsets code2 from ae2c - b4bd, 056c (1388) offsets
??? between b4bd - b4cf
Seg offsets from b4cf - end, 0bcd: 0192 (402) offsets

```
# DumpObj CODE:2
~/code/exile/status-icons/mac> head e3code2

File: Wunk:Games:Exile III v1.0.3 Ä:Exile III (fat) v1.0.3, Resource 2, Type: CODE
First jump table entry offset = $F18, Jump table entries used = 162
Segment size = $B709 [46857]
00000000: 0000 0F18       '....'          ORI.B    #$0F18,D0           
00000004: 0000 AE2C       '...,'          ORI.B    #$AE2C,D0           ; ','
00000008: 4E56 0000       'NV..'          LINK     A6,#$0000           
0000000C: 48E7 0C00       'H...'          MOVEM.L  D4/D5,-(A7)         
00000010: 382E 0008       '8...'          MOVE.W   $0008(A6),D4        
00000014: 3A2E 000A       ':...'          MOVE.W   $000A(A6),D5       
```

Offsets are 4 bytes greater in dump than in actual executable. `LINK` is really at $0004  
Reloc info starts at $ae2c  

```
# Extract A5 relocation information

```
can use 1dc6-1de2 for extra offsets

### A5

1DF0: 0292 1df2 cf 41F9 0003 0FF8 'A.....' LEA $00030FF8,A0        start 1df4(6)
1DA6: 0293 1da8 db 41F9 0003 0FF8 'A.....' LEA $00030FF8,A0        
1D5C: 0294 1d5e db 41F9 0003 0FF8 'A.....' LEA $00030FF8,A0        1d26(8) back $ce = $7f99 <--ADVEN
1CFA: 0295 1cfc cf 45F9 0003 0FF8 'E.....' LEA $00030FF8,A2        end 1cfe(1d00) back $28 = $ec

1E0C: 0310 1e0e d0 2F39 0001 CD7A '/9...z' MOVE.L $0001CD7A,-(A7)  start 1e10(2)
1DC0: 0311 1dc2 da 2F39 0001 CD7A '/9...z' MOVE.L $0001CD7A,-(A7)  1dda* back $38 = $e4
1D76: 0312 1d78 db 2F39 0001 CD7A '/9...z' MOVE.L $0001CD7A,-(A7)  1dd6* back $04 = $fe
1D2C: 0313 1d2e db 2F39 0001 CD7A '/9...z' MOVE.L $0001CD7A,-(A7)  1d70(2) back $64 = $ce <--PC_STATS_GWORLD
21DE: 0314 21e0 4259 2F39 0001 CD76 '/9...v' MOVE.L $0001CD76,-(A7)  end 21e2(4) forward $472 = $4239

1E30: 0326 1e32 db 2F39 0001 CD76 '/9...v' MOVE.L $0001CD76,-(A7)  start 1e34(6)
1DCE: 0327 1dd0 cf 2F39 0001 CD76 '/9...v' MOVE.L $0001CD76,-(A7)  1dd2* back $64 = $ce
1D84: 0328 1d86 db 2F39 0001 CD76 '/9...v' MOVE.L $0001CD76,-(A7)  1dce* back $04 = $fe
1D3A: 0329 1d3c db 2F39 0001 CD76 '/9...v' MOVE.L $0001CD76,-(A7)  1d94(6) back $38 = $e4 <--MIXED_BMP
2222: 0330 2224 4274 4879 0001 53E8 'Hy..S.' PEA $000153E8         end 2226(8) forward $492 = $4249


New a5, line 2812 derez, 0x128708 of .bin
00128708: D8D8 D8D8 D8DB DBDB CF7F 99EC DE89 4284
00128718: D8D8 D8D8 D8D8 D8D8 D8DB DBD0 E4FE CE42
00128728: 39D8 D8D8 D8D8 D8D8 D8D8 DBDB DBCE FEE4
00128738: 4249 4078 E9E9 E9D3 8840 7BFA EFFA EFFA

New seg, line 2901, 0x128c9a
00128c98: 41ED 4292 D8D8 D8D8 D8D8 D8D8 D8DB DBDB
00128ca8: C7FE EB42 D2E9 E9E7 D5E9 9A87 406B 9C87

New code, line 467, 0x11f47e of .bin

tail -n+63652 databytes |less
0x1a1f4d in .bin, 0xf8a3 in DATA0, line 3980 in derez


| status                      | x,y     | top left bottom right |
| :-------------------------- | :------ | :-------------------- |
| 0 pweapon                   | 192,157 | 009d 00c0 00a9 00cc   |
| 1 bless/curse               | 96,157  | 009d 0060 00a9 006c   |
| 2 poison (4+ very poisoned) | 0,205   | 00cd 0000 00d9 000c   |
| 3 haste/slow                | 96,169  | 00a9 0060 00b5 006c   |
| 4 invulnerable              | 192,169 | 00a9 00c0 00b5 00cc   |
| 5 magic res                 | 0,217   | 00d9 0000 00e5 000c   |
| 6 web                       | 0,181   | 00b5 0000 00c1 000c   |
| 7 disease                   | 96,181  | 00b5 0060 00c1 006c   |
| 8 sanctuary                 | 192,181 | 00b5 00c0 00c1 00cc   |
| 9 dumfound                  | 96,205  | 00cd 0060 00d9 006c   |
| 10 martys shield            | 192,205 | 00cd 00c0 00d9 00cc   |
| 11 sleep                    | 96,193  | 00c1 0060 00cd 006c   |
| 12 paralyzed                | 192,193 | 00c1 00c0 00cd 00cc   |
| 13 acid                     | 96,217  | 00d9 0060 00e5 006c   |

## DATA

```
xxd -s 0x1a1f3d -l 184 -p -c 1 e3orig.bin | ./decode-data.rb | less
xxd -s 0x1a1f3d -l 184 -p -c 1 e3orig.bin | ./decode-data.rb | ./rle-data.rb |fmt -24

~/mac> echo 00 37 $(tail -n+63654 databytes | ./decode-data.rb 2>/dev/null |head -142) |fold -w 24
00 37 00 00 00 43 00 0c 
00 37 00 0c 00 43 00 18 
00 37 00 18 00 43 00 24 
00 43 00 00 00 4f 00 0c 
00 43 00 0c 00 4f 00 18 
00 43 00 18 00 4f 00 24 
00 4f 00 00 00 5b 00 0c 
00 4f 00 0c 00 5b 00 18 
00 4f 00 18 00 5b 00 24 
00 5b 00 00 00 67 00 0c 
00 5b 00 0c 00 67 00 18 
00 5b 00 18 00 67 00 24 
00 67 00 00 00 73 00 0c 
00 67 00 0c 00 73 00 18 
00 67 00 18 00 73 00 24 
00 73 00 00 00 7f 00 0c 
00 73 00 0c 00 7f 00 18 
00 73 00 18 00 7f 00 24
```

001a1f54: 009d 0060 00a9 006c 0037 0018 0043 0024

```
~/mac> tail -n+63636 databytes |head -n 184 |fmt -24 
~/mac> tail -n+63636 databytes |head -n 184 | ./decode-data.rb  |fmt -24 
~/mac> xxd -s 0x1a1f3d -l 184 -p -c 1 e3orig.bin |fmt -24
~/mac> xxd -s 0x1a1f3d -l 184 -p -c 1 e3orig.bin | ./decode-data.rb | ./rle-data.rb |fmt -24
~/mac> xsel | sed -e 's/^ *//' -e 's/ *$//' |tr ' ' '\n' | ./rle-data.rb |fmt -w 24
# orig DATA                 orig decoded                new decoded                 new DATA
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

# put spaces between words
~/code/exile/status-icons/mac> xsel |sed 's/\([^ ][^ ]\)\([^ ][^ ]\)/\1 \2/g'
00 9d 00 c0 00 a9 00 cc
00 9d 00 60 00 a9 00 6c
00 cd 00 00 00 d9 00 0c
00 a9 00 60 00 b5 00 6c
00 a9 00 c0 00 b5 00 cc
00 d9 00 00 00 e5 00 0c
00 b5 00 00 00 c1 00 0c
00 b5 00 60 00 c1 00 6c
00 b5 00 c0 00 c1 00 cc
00 cd 00 60 00 d9 00 6c
00 cd 00 c0 00 d9 00 cc
00 c1 00 60 00 cd 00 6c
00 c1 00 c0 00 cd 00 cc
00 d9 00 60 00 e5 00 6c
 
# source rects data0 patch
001a1f3d: A042 0162 004E 016E 0012 000F 001E 001B 
001a1f4d: 009D 00C0 00A9 00CC 009D 0060 00A9 006C 
001a1f5d: 00CD 4294 D900 0C00 A900 6000 B500 6C00 
001a1f6d: A900 C000 B500 CC00 D942 84E5 000C 00B5 
001a1f7d: 42BA C100 0C00 B500 6000 C100 6C00 B500 
001a1f8d: C000 C100 CC00 CD00 6000 D900 6C00 CD00 
001a1f9d: C000 D900 CC00 C100 6000 CD00 6C00 C100 
001a1fad: C000 CD00 CC00 D900 6000 E500 6C43 8501 
001a1fbd: 7300 2400 7342 B07F 000C 0073 000C 007F 
001a1fcd: 0018 0073 0018 007F 0024 000A 0014 0008 
001a1fdd: 000A 0004 0006 000A 0007 000C 000F FFF6 
001a1fed: FFF8 FFF8 FFEC FFF8 4286 0c00 1400 6382

~/code/exile/status-icons/mac> xsel | sed -e 's/^ *//' -e 's/ *$//' |tr ' ' '\n' | ./rle-data.rb |fmt -w 24
90 42 01 62 00 4E 01 6E     A0 42 01 62 00 4E 01 6E
00 12 00 0F 00 1E 00 1B     00 12 00 0F 00 1E 00 1B
00 37 42 94 43 00 0C 00     00 9D 00 C0 00 A9 00 CC
37 00 0C 00 43 00 18 00     00 9D 00 60 00 A9 00 6C
37 00 18 00 43 00 24 00     00 CD 42 94 D9 00 0C 00
43 42 94 4F 00 0C 00 43     A9 00 60 00 B5 00 6C 00
00 0C 00 4F 00 18 00 43     A9 00 C0 00 B5 00 CC 00
00 18 00 4F 00 24 00 4F     D9 42 84 E5 00 0C 00 B5
42 94 5B 00 0C 00 4F 00     42 BA C1 00 0C 00 B5 00
0C 00 5B 00 18 00 4F 00     60 00 C1 00 6C 00 B5 00
18 00 5B 00 24 00 5B 42     C0 00 C1 00 CC 00 CD 00
94 67 00 0C 00 5B 00 0C     60 00 D9 00 6C 00 CD 00
00 67 00 18 00 5B 00 18     C0 00 D9 00 CC 00 C1 00
00 67 00 24 00 67 42 94     60 00 CD 00 6C 00 C1 00
73 00 0C 00 67 00 0C 00     C0 00 CD 00 CC 00 D9 00
73 00 18 00 67 00 18 00     60 00 E5 00 6C 43 85 01
73 00 24 00 73 42 B0 7F     73 00 24 00 73 42 B0 7F
00 0C 00 73 00 0C 00 7F     00 0C 00 73 00 0C 00 7F
00 18 00 73 00 18 00 7F     00 18 00 73 00 18 00 7F
00 24 00 0A 00 14 00 08     00 24 00 0A 00 14 00 08
00 0A 00 04 00 06 00 0A     00 0A 00 04 00 06 00 0A
00 07 00 0C 00 0F FF F6     00 07 00 0C 00 0F FF F6
FF F8 FF F8 FF EC FF F8     FF F8 FF F8 FF EC FF F8

```

### Seg bytes start at 0xb4cf

1E36: 0077 1e38 db 4EB9 0000 401A 'N...@.' JSR $0000401A    start 1e3a(c)
1DD4: 0078 1dd6 cf 4EB9 0000 401A 'N...@.' JSR $0000401A    1dca* back $72 = $c7
1D8A: 0079 1d8c db 4EB9 0000 401A 'N...@.' JSR $0000401A    1dc6* back $04 = $fe
1D40: 0080 1d42 db 4EB9 0000 401A 'N...@.' JSR $0000401A    1d9a(c) back $2a = $eb <--rect_draw_some_item
233A: 0081 233c 42fd 4EB9 0000 3B7E 'N...;~' JSR $00003B7E  end 233e(40) forward $5a4 = $42d2

