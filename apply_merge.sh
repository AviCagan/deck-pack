#!/usr/bin/env bash
# Integrates origin/main's "added big doors and other things" commit with the
# local "Add Create: Extra Gauges + Create: Linear Bearing" commit, then
# recomputes the packwiz index hash (a plain merge can't do that part) and
# pushes. Run from inside /home/deck/deck-pack-update.
set -euo pipefail
cd "$(dirname "$0")"

git fetch origin
git merge origin/main --no-commit --no-ff || true

if grep -q '<<<<<<<' pack.toml 2>/dev/null; then
  # Both sides changed the same [index].hash line - always expected here.
  # Resolve by recomputing from the (auto-merged, conflict-free) index.toml.
  python3 - <<'PY'
import hashlib, re
with open("index.toml", "rb") as f:
    data = f.read()
if b"<<<<<<<" in data:
    raise SystemExit("index.toml also has unresolved conflicts - stop and check by hand")
new_hash = hashlib.sha256(data).hexdigest()
with open("pack.toml") as f:
    pack = f.read()
pack = re.sub(r'<<<<<<<.*?=======.*?>>>>>>>[^\n]*\n', f'hash = "{new_hash}"\n', pack, flags=re.S)
pack = re.sub(r'(\[index\][^\[]*?hash = ")[0-9a-f]{64}(")', rf'\g<1>{new_hash}\g<2>', pack, count=1, flags=re.S)
with open("pack.toml", "w") as f:
    f.write(pack)
print("pack.toml hash resolved ->", new_hash)
PY
fi

git add index.toml pack.toml mods/
git commit -m "Merge: integrate big-doors update with Extra Gauges + Linear Bearing addition"
echo
echo "Merge commit created. Review with: git show --stat HEAD"
echo "Then push with: git push origin main"
