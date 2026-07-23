uv run python - <<'PY'
from pathlib import Path
from ase.io import iread, write

inp = Path("out/tip3_dimers_test.xyz")   # input multi-structure xyz
outdir = Path("out/xyz_split")
outdir.mkdir(parents=True, exist_ok=True)

for i, atoms in enumerate(iread(inp, index=":")):
    write(outdir / f"frame_{i:05d}.xyz", atoms)

print(f"Wrote {i+1} files to {outdir}")
PY
