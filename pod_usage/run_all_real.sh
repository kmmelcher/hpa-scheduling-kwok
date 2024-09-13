#!/bin/bash

startCluster(){
    echo -e "\n\033[1;32mStarting cluster\033[0m 🌩️"
    minikube start
}

stopCluster(){
    echo -e "\n\033[1;32mStopping cluster\033[0m ⛔"
    minikube stop
}

MODE=$1
OUTPUT_PATH=$2
DIRS=${3:-'*/'}

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

startCluster

for EXP_DIR in exp$DIRS ; do
    EXPERIMENT_NAME=$(basename "$EXP_DIR")

    echo "Watching cluster cost"
    bash cost.sh $MAX_DURATION > $OUTPUT_PATH/$EXPERIMENT_NAME-cost.csv &
    
    echo "Running experiment: $EXPERIMENT_NAME"
    bash run.sh "$METRICS_FILEPATH" "$PROMETHEUS_HOST" "$SCRAPE_INTERVAL" "$OUTPUT_PATH" "$EXPERIMENT_NAME" "$MAX_DURATION" "$PLOT_DIR" "$MODE"
    echo "Experiment $EXPERIMENT_NAME finished"
done

stopCluster
