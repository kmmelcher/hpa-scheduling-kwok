#!/bin/bash

# Defina aqui os valores que deseja passar para o script
EXPERIMENT_NAME="kilian-tcc-1"
METRICS_FILEPATH="../../metrics_collector/metrics.txt"
PROMETHEUS_HOST="http://localhost:9090"
SCRAPE_INTERVAL="10m"
OUTPUT_DIR="output_1"
MAX_DURATION=600
PLOT_DIR="plots"

# Encontra diretórios que começam com "exp" e executa o script para cada um
for EXP_DIR in exp*/ ; do
    EXPERIMENT_NAME=$(basename "$EXP_DIR")
    
    echo "Running experiment: $EXPERIMENT_NAME"
    ./run.sh "$METRICS_FILEPATH" "$PROMETHEUS_HOST" "$SCRAPE_INTERVAL" "$OUTPUT_DIR" "$EXPERIMENT_NAME" "$MAX_DURATION" "$PLOT_DIR"
    echo "Experiment $EXPERIMENT_NAME finished"
done
