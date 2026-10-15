#!/usr/bin/env python3
"""Khoi phuc file nhi phan sau khi clone (chi chay 1 lan).
Cac file .b64 la ban base64 cua file goc (do kenh push khong ho tro binary).
Chay: python tools/restore_binaries.py   (hoac python3)
"""
import base64
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
count = 0
for dirpath, _dirs, filenames in os.walk(ROOT):
    if "tools" in dirpath.split(os.sep) and os.path.basename(dirpath) == "tools":
        pass
    for fn in filenames:
        if fn.endswith(".b64"):
            sidecar = os.path.join(dirpath, fn)
            orig = sidecar[:-4]
            with open(sidecar, "r") as f:
                data = base64.b64decode(f.read())
            with open(orig, "wb") as f:
                f.write(data)
            os.remove(sidecar)
            count += 1
            print("restored:", os.path.relpath(orig, ROOT))
print(f"Xong: {count} file nhi phan da duoc khoi phuc.")
