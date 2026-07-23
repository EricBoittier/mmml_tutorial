import csv
rows = list(csv.DictReader(open("orient_new_DCM/rays.csv")))
rows.sort(key=lambda r: float(r["e_min_kcal"]))
print("DEEPEST:", ",".join(r["ray"] for r in rows[:3]))
for r in rows[:3]:
    print(f"  ray {r['ray']:>4} depth={r['e_min_kcal']} r={r['r_at_min']} n_min_ml={r['n_min_ml']}")
