hipotese:
* O HPA usa uma média ponderada da utilização dos containers, para definir a utilização de um Pod
* pod_usage = (container_a_usage * container_a_resource_request + container_b_usage * container_b_resource_request) / (container_a_resource_request + container_b_resource_request)

1 e 3 
- elimina média aritimetica e considerar apenas um container
2 e 4
- 
Média Ponderada: A utilização percentual do Pod é calculada como uma média ponderada da utilização de CPU em relação às solicitações de CPU de todos os contêineres no Pod. Isso significa que a utilização de CPU de cada contêiner é comparada com sua própria solicitação de CPU, e a média ponderada dessas utilizações proporciona a métrica de utilização para o HPA.

falta
- usando averageValue
- usando containers


### Scenario 1
* Resource: CPU
* Container A
  * Resource request: 1000m
  * Resource usage: 700m (70%)
* Container B:
  * Resource request: 1000m
  * Resource usage: 200m (20%)
* HPA:
  * target utilization: 55%
* Usage: 45%
* Average: 45%

### Scenario 2
* Resource: CPU
* Container A
  * Resource request: 500m
  * Resource usage: 500m (100%)
* Container B:
  * Resource request: 2000m
  * Resource usage: 500m (25%)
* HPA:
  * target utilization: 55%
* Usage: 40%
* Average: 62.5%

### Scenario 3
* Resource: CPU
* Container A
  * Resource request: 500m
  * Resource usage: 100m (20%)
* Container B:
  * Resource request: 2000m
  * Resource usage: 1300m (65%)
* HPA:
  * target utilization: 50%
* Usage: 56%
* Average:42.5%

### Scenario 4
* Resource: Memory
* Container A
  * Resource request: 100M
  * Resource usage: 70M (70%)
* Container B:
  * Resource request: 100M
  * Resource usage: 20M (20%)
* HPA:
  * target utilization: 55%

### Scenario 5
* Resource: Memory
* Container A
  * Resource request: 100M
  * Resource usage: 100M (100%)
* Container B:
  * Resource request: 400M
  * Resource usage: 100M (25%)
* HPA:
  * target utilization: 55%

### Scenario 6
* Resource: Memory
* Container A
  * Resource request: 250M
  * Resource usage: 50M (20%)
* Container B:
  * Resource request: 1000M
  * Resource usage: 650M (65%)
* HPA:
  * target utilization: 50%