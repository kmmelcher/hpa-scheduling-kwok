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

echo -e "\n\033[1;32mCreating deployment\033[0m 🔧"
kubectl apply -f $EXPERIMENT_NAME/deploy-${EXPERIMENT_MODE}.yaml

echo -e "\n\033[1;32mCreating HPA\033[0m 🔨"
kubectl apply -f $EXPERIMENT_NAME/hpa.yaml

COUNTER=`kubectl get pods | grep -v NAME | wc -l`

echo -e "\n\033[1;32mWaiting for pods to be created\033[0m 🥱"

while [ $COUNTER -eq 0 ]; do
        sleep 1
        COUNTER=`kubectl get pods | grep -v NAME | wc -l`
        echo "Waiting... 😴"
done

echo -e "\n\033[1;32mPods are running\033[0m 🏃‍♂️‍➡️"
echo -e "Waiting for $MAX_DURATION seconds to finish the experiment."
while [  $COUNTER -ne 0 ]; do
        sleep 1
        AGGR_TIME=$((AGGR_TIME+1))
        COUNTER=`kubectl get pods | grep -v NAME | wc -l`

        echo "Time elapsed: $AGGR_TIME seconds"
        
        if [ $AGGR_TIME -gt $MAX_DURATION ]
        then
                echo -e "\nDeleting all deployments, services and jobs from default namespace"
                kubectl delete deployment --all --namespace=default
                kubectl delete hpa --all --namespace=default
        fi
done

echo "Experiment execution is terminating. 💀"
sleep 10

echo "Collecting metrics from Prometheus 📊"
python3 ../metrics_collector/src/main.py $METRICS_FILEPATH $PROMETHEUS_HOST $SCRAPE_INTERVAL $OUTPUT_PATH $EXPERIMENT_NAME

# sleep 10
# echo -e "\nGenerating plots"

# METRIC=$(grep -A 1 'resource:' $EXPERIMENT_NAME/hpa.yaml | grep 'name:' | awk '{print $2}')

# Rscript ../plots/plot.R $METRIC $EXPERIMENT_NAME $OUTPUT_PATH/$EXPERIMENT_NAME.csv $OUTPUT_PATH
