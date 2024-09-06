#!/bin/bash

createCluster(){
  echo -e "\n\033[1;32mCreating cluster\033[0m 🌩️"

  kwokctl create cluster \
    --prometheus-port 9090 \
    --enable-metrics-server \
    --enable-crds Metric,ClusterResourceUsage,ResourceUsage \
    --name experiment

  kubectl apply -f ../metrics_collector/metrics.yaml

  echo -e "\n\033[1;32mCreating node\033[0m ⛏️"

  kwokctl scale node --replicas 1 --name experiment
}

deleteCluster(){
  kwokctl delete cluster --name experiment
}

MODE=$1
DIRS=${2:-'*/'}

if [ "$DIRS" == '*/' ]; then
    EXPERIMENTS="1, 2, 3, 4, 5, 6"
else
    EXPERIMENTS="$DIRS"
fi

echo "🧪 Experiment Summary"
echo "🔧 Mode: $MODE"
echo "🔬 Experiment(s): $EXPERIMENTS"
echo "📊 Metrics Filepath: $METRICS_FILEPATH"
echo "🌐 Prometheus Host: $PROMETHEUS_HOST"
echo "⏲️  Scrape Interval: $SCRAPE_INTERVAL"
echo "📁 Output Directory: $OUTPUT_DIR"
echo "⏳ Max Duration: ${MAX_DURATION}s"
echo "📈 Plot Directory: $PLOT_DIR"
echo ""


createCluster

for EXP_DIR in exp$DIRS ; do
    EXPERIMENT_NAME=$(basename "$EXP_DIR")

    echo "Watching cluster cost"
    bash cost.sh $MAX_DURATION > ../output/$OUTPUT_DIR/$EXPERIMENT_NAME-cost.csv &
    
    echo "Running experiment: $EXPERIMENT_NAME"
    bash run.sh "$METRICS_FILEPATH" "$PROMETHEUS_HOST" "$SCRAPE_INTERVAL" "$OUTPUT_DIR" "$EXPERIMENT_NAME" "$MAX_DURATION" "$PLOT_DIR" "$MODE"
    echo "Experiment $EXPERIMENT_NAME finished"
done

deleteCluster
