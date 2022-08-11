# Keys

Exile I
handle_keystroke CODE2

DATA0 resource length c2a7
dd iflag=count_bytes,skip_bytes count=$((0xc2a7)) skip=2333915 if=e1orig.bin of=e1d0raw.dat


## Part 1 Extract the Original Switch Cases

d68 e1orig.bin 2424714 146 | \
awk '
  BEGIN {
    c = 53
  }
  /SUB/ {
    gsub("^.*#","0x");
    gsub(",.*","");
    gsub("[$]","");
    c = c + strtonum($0);
    printf "%c\t%c\t", c, c
  }
  /BEQ/ {
    sub(".*BEQ *","");
  print
  }' > new-keys.txt

## Part 2 Edit In the New Keys

*insert the new keys in the first column*
6   6	$00000096
9   9	$000000f8
=   =	$00000114
A   A	$00000250
F   F	$000001a4
N   G	$000001d6
V   L	$00000250
C   M	$00000304
R   P	$00000304
a   a	$00000202
b   b	$00000250
d   d	$00000304
e   e	$000002aa
f   f	$00000304
g   g	$00000304
v   l	$00000304
c   m	$00000304
r   p	$00000304
Z   r	$0000038e
s   s	$000002aa
t   t	$00000304
w   w	$00000304
x   x	$000002aa
z   z	$0000012e

### Change r(Z) Branch Destination

We need extra space for subi.w instructions in the second switch,
so we will skip one case. The redundant cases are [d,f,r,t]. We will
skip r(Z) and go straight to the destination in the first switch.
So the destination will be (a392 - a308) farther away

Z   r	$00000304 -> $0000038e

## Part 3 Write the New Switch Code

```sh
$ LC_COLLATE=C sort new-keys.txt | awk ' 
BEGIN {
  pre=53;
  for(n=0;n<256;n++) ord[sprintf("%c",n)]=n
}
{
  cur=ord[$1];
  delta=cur-pre;
  pre=cur;
  if (delta > 8) {
    printf "\tSUBI.W\t#$00%x", delta
  } else {
    printf "\tSUBQ.W\t#$%x", delta
  }
  printf ",D0\t;%c\n\tBEQ\t%s\n", $1"", $3
}' > /tmp/in.asm ; asm68k -l /tmp/out.lst -- /tmp/in.asm ; cat /tmp/out.lst

$ grep 'SUB\|BEQ' /tmp/out.lst |cut -c10-18 |xxd -r -p |hd
$ vimdiff <(xxd -s 2424714 -l 146 e1orig.bin |cut -c-49) <(grep 'SUB\|BEQ' /tmp/out.lst |cut -c10-18 |xxd -r -p -s 2424714 |xxd -s 2424714 -l 146 |cut -c-49)

$ xxd -s 2424714 -l 146 e1orig.bin |cut -c-49
0024ff8a: 5340 6700 0092 5740 6700 00ee 5940 6700
0024ff9a: 0104 5940 6700 023a 5b40 6700 0188 5340
0024ffaa: 6700 01b4 5b40 6700 0228 5340 6700 02d6
0024ffba: 5740 6700 02d0 0440 0011 6700 01c6 5340
0024ffca: 6700 020e 5540 6700 02bc 5340 6700 025c
0024ffda: 5340 6700 02b0 5340 6700 02aa 5b40 6700
0024ffea: 02a4 5340 6700 029e 5740 6700 0298 5540
0024fffa: 6700 0292 5340 6700 0232 5340 6700 0286
0025000a: 5740 6700 0280 5340 6700 0220 5540 6700
0025001a: 009e

$ grep 'SUB\|BEQ' /tmp/out.lst |cut -c10-18 |xxd -r -p -s 2424714 |xxd -s 2424714 -l 146 |cut -c-49
0024ff8a: 5340 6700 0092 5740 6700 00ee 5940 6700
0024ff9a: 0104 5940 6700 023a 5540 6700 02e8 5740
0024ffaa: 6700 0182 5140 6700 01ae 5940 6700 02d6
0024ffba: 5940 6700 021c 5940 6700 0354 5f40 6700
0024ffca: 01c2 5340 6700 020a 5340 6700 02b8 5340
0024ffda: 6700 02b2 5340 6700 0252 5340 6700 02a6
0024ffea: 5340 6700 02a0 0440 000b 6700 0298 5340
0024fffa: 6700 0238 5340 6700 028c 5540 6700 0286
0025000a: 5340 6700 0280 5340 6700 0220 5540 6700
0025001a: 009e
```

## The second switch

```sh
$ python3 -c 'print(open("e1orig.bin", "rb").read().find(b"\x04\x40\x00\x4D\x67\x34"))'
2425520
$ d68 e1orig.bin 2425520 54
00000000 : 0440 004d      SUBI.W   #$004D,D0
00000004 : 6734           BEQ      $0000003a
00000006 : 5740           SUBQ.W   #3,D0
00000008 : 6744           BEQ      $0000004e
0000000a : 0440 0014      SUBI.W   #$0014,D0
0000000e : 6700 00de      BEQ      $000000ee
00000012 : 5540           SUBQ.W   #2,D0
00000014 : 6700 00fa      BEQ      $00000110
00000018 : 5340           SUBQ.W   #1,D0
0000001a : 6700 00e4      BEQ      $00000100
0000001e : 5b40           SUBQ.W   #5,D0
00000020 : 6740           BEQ      $00000062
00000022 : 5340           SUBQ.W   #1,D0
00000024 : 6722           BEQ      $00000048
00000026 : 5740           SUBQ.W   #3,D0
00000028 : 6732           BEQ      $0000005c
0000002a : 5540           SUBQ.W   #2,D0
0000002c : 673a           BEQ      $00000068
0000002e : 5540           SUBQ.W   #2,D0
00000030 : 674a           BEQ      $0000007c
00000032 : 5740           SUBQ.W   #3,D0
00000034 : 675c           BEQ      $00000092
```

d68 e1orig.bin 2425520 54 | \
awk '
  BEGIN {
    c = 0
  }
  /SUB/ {
    gsub("^.*#","0x");
    gsub(",.*","");
    gsub("[$]","");
    c = c + strtonum($0);
    printf "%c\t%c\t", c, c
  }
  /BEQ/ {
    sub(".*BEQ *","");
  print
  }'

C	M	$0000003a
R	P	$0000004e
d	d	$000000ee
f	f	$00000110
g	g	$00000100
v	l	$00000062
c	m	$00000048
r	p	$0000005c
Z	r	$00000068
t	t	$0000007c
w	w	$00000092

We don't need [d,f,t,r] in the second switch, so we'll omit r (Z)

C	M	$0000003a
R	P	$0000004e
d	d	$000000ee
f	f	$00000110
g	g	$00000100
v	l	$00000062
c	m	$00000048
r	p	$0000005c
t	t	$0000007c
w	w	$00000092

LC_COLLATE=C sort new-keys2.txt | awk ' 
BEGIN {
  pre=0;
  for(n=0;n<256;n++) ord[sprintf("%c",n)]=n
}
{
  cur=ord[$1];
  delta=cur-pre;
  pre=cur;
  if (delta > 8) {
    printf "\tSUBI.W\t#$00%x", delta
  } else {
    printf "\tSUBQ.W\t#$%x", delta
  }
  printf ",D0\t;%c\n\tBEQ\t%s\n", $1"", $3
}' > /tmp/in2.asm ; asm68k -l /tmp/out2.lst -- /tmp/in2.asm ; cat /tmp/out2.lst

grep 'SUB\|BEQ' /tmp/out2.lst |cut -c10-18 |xxd -r -p |hd

vimdiff <(xxd -s 2425520 -l 54 e1orig.bin |cut -c-49) \
        <(grep 'SUB\|BEQ' /tmp/out2.lst |cut -c10-18 |xxd -r -p -s 2425520 |xxd -s 2425520 -l 54 |cut -c-49)

### The second switch patch

```sh
$ xxd -s 2425520 -l 54 e1orig.bin |cut -c-49
002502b0: 0440 004d 6734 5740 6744 0440 0014 6700
002502c0: 00de 5540 6700 00fa 5340 6700 00e4 5b40
002502d0: 6740 5340 6722 5740 6732 5540 673a 5540
002502e0: 674a 5740 675c

$ grep 'SUB\|BEQ' /tmp/out2.lst |cut -c10-18 |xxd -r -p -s 2425520 |xxd -s 2425520 -l 54 |cut -c-49
002502b0: 0440 0043 6734 0440 000f 6742 0440 0011
002502c0: 6736 5340 6700 00d8 5540 6700 00f4 5340
002502d0: 6700 00de 0440 000b 6732 5540 674e 5540
002502e0: 6730 5340 675c
```


## The Town Buttons (Alchemy, Bash, Pick Lock - A, L, b)

The check for 'L' will change to 'V'

```sh
0000A274: 0C05 004C       '...L'          CMPI.B   #$4C,D5             ; 'L'
0000A278: 6706            'g.'            BEQ.S    *+$0008             ; 0000A280

$ python3 -c 'print(open("e1orig.bin", "rb").read().find(b"\x0C\x05\x00\x4C\x67\x06"))'
2425338
$ d68 e1orig.bin 2425338 6
00000000 : 0c05 004c      CMPI.B   #$4C,D5
00000004 : 6706           BEQ      $0000000c

$ xxd -s 2425338 -l 16 e1orig.bin 
002501fa: 0c05 004c 6706 303c 0192 6004 303c 01a3  ...Lg.0<..`.0<..
$ python3 -c "print([hex(ord(x)) for x in 'LV'])"
['0x4c', '0x56']
```

002501fa: 0c05 004c 6706 303c 0192 6004 303c 01a3
002501fa: 0c05 0056 6706 303c 0192 6004 303c 01a3

## The Combat Buttons (e, s, x)

Did not change


## The Complete Patch

00242e6d: 0c2b 2f2c 2825 2922 1f23 2325 0100 2125  RSTUVWXY[\#%..!%
0024ff8a: 5340 6700 0092 5740 6700 00ee 5940 6700
0024ff9a: 0104 5940 6700 023a 5540 6700 02e8 5740
0024ffaa: 6700 0182 5140 6700 01ae 5940 6700 02d6
0024ffba: 5940 6700 021c 5940 6700 0354 5f40 6700
0024ffca: 01c2 5340 6700 020a 5340 6700 02b8 5340
0024ffda: 6700 02b2 5340 6700 0252 5340 6700 02a6
0024ffea: 5340 6700 02a0 0440 000b 6700 0298 5340
0024fffa: 6700 0238 5340 6700 028c 5540 6700 0286
0025000a: 5340 6700 0280 5340 6700 0220 5540 6700
0025001a: 009e 6000 03f4 1005 4880 0640 ffcf c1fc
002501fa: 0c05 0056 6706 303c 0192 6004 303c 01a3
002502b0: 0440 0043 6734 0440 000f 6742 0440 0011
002502c0: 6736 5340 6700 00d8 5540 6700 00f4 5340
002502d0: 6700 00de 0440 000b 6732 5540 674e 5540
002502e0: 6730 5340 675c 6000 00e8 13fc 0001 0001

## Change the Numpad Keys

The only thing left to do is locate the array of keypad codes. The Macintosh's
keyboard encodes the numeric keypad keys as `0x52-0x5c` for `0-9` with `0x5a`
being skipped. Searching the game file for an array of those values yields:

```sh
$ python3 -c "print(open('e1orig.bin','rb').read().find(b'\x52\x53\x54\x55\x56\x57\x58\x59\x5b\x5c'))"
2371181
$ xxd -s 2371181 -l 16 e1orig.bin
00242e6d: 5253 5455 5657 5859 5b5c 2325 0100 2125  RSTUVWXY[\#%..!%
```

The Macintosh key codes for the replacement keys (`[,./][kl;][iop]`) are
`[2b2f2c][282529][221f23]`. Finally let's substitute numeric keypad `0` with `q`
(`0x0c` on the Mac). Keypad `0` does the same thing as `z` in the game, but we
might as well grab it while we're here just in case it matters.

00242e6d: 0c2b 2f2c 2825 2922 1f23 2325 0100 2125  RSTUVWXY[\#%..!%
