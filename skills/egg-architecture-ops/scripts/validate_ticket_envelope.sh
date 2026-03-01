#!/usr/bin/env bash
set -euo pipefail
SCHEMA="$HOME/.openclaw/workspace/skills/egg-architecture-ops/references/contract-schema.json"
INPUT="${1:-}"
[ -n "$INPUT" ] || { echo "usage: $0 <json-file>"; exit 1; }
python3 - <<PY
import json,sys
schema=json.load(open('$SCHEMA'))
data=json.load(open('$INPUT'))
req=schema['required']
missing=[k for k in req if k not in data]
if missing:
  print('INVALID missing:', ','.join(missing)); sys.exit(2)
if data.get('priority') not in ['P0','P1','P2']:
  print('INVALID priority'); sys.exit(2)
if data.get('sensitivity') not in ['public','internal','restricted']:
  print('INVALID sensitivity'); sys.exit(2)
print('VALID')
PY
