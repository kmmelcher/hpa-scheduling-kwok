#!/bin/bash

set -a && source .env && set +a

MODE=${1:-'real'}
FILTER=${2:-}

if [[ "$MODE" != "real" && "$MODE" != "emulation" ]]; then
  echo "Error: MODE must be either 'real' or 'emulation'"
  exit 1
fi

if [[ -n "$FILTER" && !"$FILTER" =~ ^[1-6]$ ]]; then
  echo "Error: FILTER must be from 1 to 6 or empty"
  exit 1
fi


cd pod_usage
bash run_all.sh $MODE $FILTER