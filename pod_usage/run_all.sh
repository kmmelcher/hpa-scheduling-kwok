#!/bin/bash

# Encontra diretórios que começam com "exp" e executa o script para cada um
for EXP_DIR in exp*/ ; do
    EXPERIMENT_NAME=$(basename "$EXP_DIR")
    
    echo "Running experiment: $EXPERIMENT_NAME"
    bash run.sh "$METRICS_FILEPATH" "$PROMETHEUS_HOST" "$SCRAPE_INTERVAL" "$OUTPUT_DIR" "$EXPERIMENT_NAME" "$MAX_DURATION" "$PLOT_DIR"
    echo "Experiment $EXPERIMENT_NAME finished"
done
