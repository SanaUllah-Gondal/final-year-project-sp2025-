# Rebuild the original folder structure from mixed files.
# Usage:
#   python reconstruct.py
import os, shutil, pathlib

BASE = pathlib.Path(__file__).parent
OUT = BASE / "reconstructed"
if OUT.exists():
    shutil.rmtree(OUT)
OUT.mkdir(parents=True)

for item in BASE.iterdir():
    if item.is_file() and "__" in item.name and item.name != "reconstruct.py":
        parts = item.name.split("__")
        # First token indicates top-level (laravel/flutter)
        dest = OUT / "/".join(parts)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(item, dest)
        print("Restored:", dest.relative_to(OUT))
print("\nDone. See /reconstructed folder.")
