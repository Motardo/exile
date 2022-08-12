#!/usr/bin/env python3

# Find a named procedure in 68k code

import sys
import re

if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} filename string")
    sys.exit(1)

file_name = sys.argv[1].encode('utf-8')
proc_search = sys.argv[2].encode('utf-8')
linka6 = b'\x4E\x56'
unlink = b'\x4E\x5E\x4E\x75'

query = re.escape(unlink) + b'.[_A-z]*' + proc_search

with open(file_name,'rb') as fh:
    file_bytes = fh.read()

matches = [m for m in re.finditer(query, file_bytes)]
if (len(matches) < 1):
    print("Not found")
    sys.exit(2)

print("Procedure                        start     end       size")
for m in matches:
    debug_str = m.span()[0]
    proc_start = file_bytes.rfind(linka6, 0, debug_str)

    if proc_start == -1:
        continue

    proc_end = debug_str + 4

    proc_name_length = file_bytes[proc_end]
    if proc_name_length > 127:
        proc_name_length -= 128

    proc_name = file_bytes[proc_end + 1 : proc_end + 1 + proc_name_length].decode('utf-8')
    proc_size = debug_str - proc_start
    print(f"{proc_name:30s}{proc_start:10d}{proc_end:10d}{proc_end - proc_start:6d}")
