# Kubernetes HPA Experiment Automation CLI

This project is a CLI tool to automate the execution of aa Kubernetes experiment.
This CLI allows you to run this Kubernetes experiment on a real cluster using Minikube
and on a KWOK cluster.

## The Experiment

Consider a scenario where a pod contains two containers inside of it.
How will the HPA calculate the pod usage?
- The max container usage?
- The average container usage?
- The total usage?

Those scenarious were tested in conditions where the cpu and memory usage was higher than the HPA target.
In total there are 6 scenarious:
1. Max cpu container usage higher than target
2. Average cpu container higher than target
3. Total cpu usage higher than target
4. Max memory container usage higher than target
5. Average memory container higher than target
6. Total memory usage higher than target

Then, it checks if the HPA scaled up or not.

## Prerequisites

For the real experiment
- [Minikube Cluster](https://minikube.sigs.k8s.io/docs/start/?arch=%2Flinux%2Fx86-64%2Fstable%2Fbinary+download) with Kuberentes v1.23
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) v1.23
- [Helm](https://helm.sh/docs/intro/install/#from-apt-debianubuntu )
- [Metrics Server](https://artifacthub.io/packages/helm/metrics-server/metrics-server )
- [Prometheus](https://artifacthub.io/packages/helm/prometheus-community/prometheus)

For the emulated experiment
- [KWOK](https://kwok.sigs.k8s.io/docs/user/installation/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) (any version)

## Run

Run real experiments

```
bash run.sh real
```

Run emulation experiments

```
bash run.sh emulation
```

Run a specific experiment, such as experiment 2:
```
bash run.sh real 2
```

## Results

The HPA only scaled up on scenarious 3 and 6, where the total usage was higher than the target.
