import csv, sys
rows = list(csv.DictReader(open(sys.argv[1])))
rows.sort(key=lambda r: float(r["e_min_kcal"]))
print("deepest:", ",".join(r["ray"] for r in rows[:2]))
bad = [r for r in rows if int(r["n_min_ml"]) > 1]
bad.sort(key=lambda r: float(r["e_min_kcal"]))
print("spurious:", ",".join(r["ray"] for r in bad[:2]))
