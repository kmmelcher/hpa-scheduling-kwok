#!/bin/bash

# Load environment variables from .env
set -a && source .env && set +a

cd pod_usage
bash run_all.sh