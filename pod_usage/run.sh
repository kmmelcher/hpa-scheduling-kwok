#!/bin/bash

METRICS_FILEPATH=$1
PROMETHEUS_HOST=$2
SCRAPE_INTERVAL=$3
OUTPUT_DIR=$4
EXPERIMENT_NAME=$5
MAX_DURATION=$6
PLOT_DIR=$7
EXPERIMENT_MODE=$8

OUTPUT_PATH="../output/$OUTPUT_DIR"
AGGR_TIME=0

kubectl apply -f $EXPERIMENT_NAME/hpa.yaml,$EXPERIMENT_NAME/deploy-${EXPERIMENT_MODE}.yaml
COUNTER=`kubectl get pods | grep -v NAME | wc -l`

while [ $COUNTER -eq 0 ]; do
        sleep 1
        COUNTER=`kubectl get pods | grep -v NAME | wc -l`
        echo "Waiting for pods to be created"
done

echo "There are pods running. Waiting for $MAX_DURATION seconds to finish the experiment."
while [  $COUNTER -ne 0 ]; do
        sleep 1
        AGGR_TIME=$((AGGR_TIME+1))
        COUNTER=`kubectl get pods | grep -v NAME | wc -l`

        echo "Time elapsed: $AGGR_TIME seconds"
        
        if [ $AGGR_TIME -gt $MAX_DURATION ]
        then
                echo "Deleting all deployments, services and jobs from default namespace"
                kubectl delete deployment --all --namespace=default
                kubectl delete hpa --all --namespace=default
        fi
done

echo "Experiment execution is terminating."
sleep 10

echo "Collecting metrics from Prometheus"
python3 ../metrics_collector/src/main.py $METRICS_FILEPATH $PROMETHEUS_HOST $SCRAPE_INTERVAL $OUTPUT_PATH $EXPERIMENT_NAME

sleep 10
echo "Generating tables"

METRIC=$(grep -A 1 'resource:' $EXPERIMENT_NAME/hpa.yaml | grep 'name:' | awk '{print $2}')

Rscript ../plots/plot.R $METRIC $EXPERIMENT_NAME $OUTPUT_PATH/$EXPERIMENT_NAME.csv $OUTPUT_PATH
