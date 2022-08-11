# Instant Help Off by Default

When starting a new game, all stuff-done flags are cleared which resets the `Never Show Instant Help` option.
This patch ensures that the option is set. The relevant routine is called `init_party`

### Exile 3 Windows Original

```
~/code/exile/instant-help> ndisasm -k 0,0xe4bd7 ~/dos/c/EXILE3/EXILE3.EXE | head -20
00000000  skipping 0xE4BD7 bytes
000E4BD7  33F6              xor si,si
000E4BD9  EB1B              jmp short 0x4bf6
000E4BDB  33FF              xor di,di
000E4BDD  EB11              jmp short 0x4bf0
000E4BDF  8BDE              mov bx,si
000E4BE1  6BDB0A            imul bx,bx,byte +0xa
000E4BE4  B80000            mov ax,0x0
000E4BE7  8EC0              mov es,ax
000E4BE9  26C681840000      mov byte [es:bx+di+0x84],0x0
000E4BEF  47                inc di
000E4BF0  83FF0A            cmp di,byte +0xa
000E4BF3  7CEA              jl 0x4bdf
000E4BF5  46                inc si
000E4BF6  81FE3601          cmp si,0x136
000E4BFA  7CDF              jl 0x4bdb
```

### Blades Win

```
000D7A70  33F6              xor si,si
000D7A72  EB1B              jmp short 0x7a8f
000D7A74  33FF              xor di,di
000D7A76  EB11              jmp short 0x7a89
000D7A78  8BDE              mov bx,si
000D7A7A  6BDB0A            imul bx,bx,byte +0xa
000D7A7D  B80000            mov ax,0x0
000D7A80  8EC0              mov es,ax
000D7A82  26C681080000      mov byte [es:bx+di+0x8],0x0
000D7A88  47                inc di
000D7A89  83FF0A            cmp di,byte +0xa
000D7A8C  7CEA              jl 0x7a78
000D7A8E  46                inc si
000D7A8F  81FE3601          cmp si,0x136
000D7A93  7CDF              jl 0x7a74
```

### New Code

```
;; org 0xd7a72

;; start here to clobber some jumps in the original, then pad out the reloc to match the original
	times 7 db 0x90 ; nop

	xor bx,bx
	jmp short next
loop:
	mov ax,0  ; this reloc will stay put
	mov es,ax
	mov byte [es:bx+0x8],byte 0x0
	inc bx
next:
	cmp bx, +0xc1c	; 3100
	jl loop
	mov bx,0xc00	; 3064 + 8, [306][4] is never-show-instant-help
	mov byte [es:bx],byte 0x1
```

### Patch File

```
Win Blades
000d7a72: 9090 9090 9090 9031 dbeb 0bb8 0000 8ec0
000d7a82: 26c6 4708 0043 81fb 1c0c 7cef bb00 0c26
000d7a92: c607 01b8 0000 8ec0 26c7 0664 1200 00b8

Win Exile 3
000e4bd9: 9090 9090 9090 bb84 00eb 0ab8 0000 8ec0
000e4be9: 26c6 0700 4381 fba0 0c7c f0bb 7c0c 26c6
000e4bf9: 0701 9033 ffeb 0cb8 0000 8ec0 26c6 855a

Mac Blades
0010c93e: 4e71 4e71 4e71 7a00 600c 41f9 0002 b6be
0010c94e: 4230 5008 5245 0c45 0c1c 6dee 3a3c 0bf8
0010c95e: 11b8 0001 5008 4279 0002 c922 13fc 0007

Mac Exile 3
original
001476b3: 7c00 6020 7a00 6014 700a c1c6 41f9 0002
001476c3: 883e d1c0 d0c5 4228 0084 5245 0c45 000a
001476d3: 6de6 5246 0c46 0136 6dda 7a00 6010 41f9

instant help patch
001476b3: 4E71 4E71 4E71 3A3C 0084 600C 41F9 0002 
001476c3: 883E 4230 5000 5245 0C45 0CA0 6DF4 3A3C 
001476d3: 0C7C 11B8 0001 5000 4E71 7a00 6010 41f9

```
