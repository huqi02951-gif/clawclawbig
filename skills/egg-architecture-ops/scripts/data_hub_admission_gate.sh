#!/usr/bin/env bash
set -euo pipefail
REG="$HOME/.openclaw/state/data_hub_registry.json"
RULES="$HOME/.openclaw/ops/priority_router_rules.json"
OUT="$HOME/.openclaw/audits/data_hub_admission_latest.json"
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

python3 - <<PY
import json, os
reg=json.load(open(os.path.expanduser('$REG')))
rules=json.load(open(os.path.expanduser('$RULES')))
issues=[]
for d in reg.get('departments',[]):
    if 'groupId' not in d or 'ownerAgent' not in d:
        issues.append(f"department_meta_missing:{d.get('name','unknown')}")
    for e in d.get('employees',[]):
        for k in ['topic','name','role','defaultModel','priorityBand']:
            if k not in e:
                issues.append(f"employee_field_missing:{d.get('name')}:{e.get('name','unknown')}:{k}")
        if e.get('priorityBand') not in rules.get('bands',{}):
            issues.append(f"priority_invalid:{d.get('name')}:{e.get('name','unknown')}")

out={
  'timestamp':'$TS',
  'departments':len(reg.get('departments',[])),
  'employees':sum(len(d.get('employees',[])) for d in reg.get('departments',[])),
  'issues':issues
}
json.dump(out, open(os.path.expanduser('$OUT'),'w'), ensure_ascii=False, indent=2)
print(os.path.expanduser('$OUT'))
PY
