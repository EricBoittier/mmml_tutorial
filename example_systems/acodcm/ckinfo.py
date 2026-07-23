import json
import sys
from pathlib import Path
from mmml.models.physnetjax.physnetjax.restart.restart import get_last, orbax_checkpointer
CK = sys.argv[1]
last = get_last(CK)
print("latest epoch:", Path(last).name)
r = orbax_checkpointer.restore(last)
print("keys:", sorted(r.keys()))
print("hybrid_mm  :", json.dumps(r.get("hybrid_mm"), default=str))
ma = r.get("model_attributes") or {}
for k in ("cutoff", "features", "num_iterations", "charges", "zbl",
          "max_atomic_number", "n_res", "natoms", "include_electrostatics"):
    if k in ma:
        print(f"  {k:22s} {ma[k]}")
print("epoch:", r.get("epoch"), " best_loss:", r.get("best_loss"))
