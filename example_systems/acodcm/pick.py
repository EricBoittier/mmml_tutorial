import csv
rows = list(csv.DictReader(open("orient_6A/rays.csv")))
bad = sorted([r for r in rows if int(r["n_min_ml"]) > 1], key=lambda r: float(r["e_min_kcal"]))
ok = [r for r in rows if int(r["n_min_ml"]) == 1]
print("SPURIOUS:", ",".join(r["ray"] for r in bad[:3]))
print("CLEAN:", ",".join(r["ray"] for r in ok[:2]))
for r in bad[:3]:
    print(f"  ray {r['ray']:>4} n_min_ml={r['n_min_ml']} depth={r['e_min_kcal']} r={r['r_at_min']}")
