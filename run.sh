#!/bin/bash

createDir() {
  local directory=$1

  if [ ! -d "$directory" ]; then
    mkdir -p "$directory"
    echo "Created output directory: $directory"
  else
    echo "Using existing output directory: $directory"
  fi
}

set -a && source .env && set +a

MODE=${1:-'real'}
FILTER=${2:-}
OUTPUT_PATH="../output/$OUTPUT_DIR"

if [[ "$MODE" != "real" && "$MODE" != "emulation" ]]; then
  echo "Error: MODE must be either 'real' or 'emulation'"
  exit 1
fi

if [[ -n "$FILTER" && !"$FILTER" =~ ^[1-6]$ ]]; then
  echo "Error: FILTER must be from 1 to 6 or empty"
  exit 1
fi

cd pod_usage
createDir $OUTPUT_PATH

bash run_all_$MODE.sh $MODE $OUTPUT_PATH $FILTER
