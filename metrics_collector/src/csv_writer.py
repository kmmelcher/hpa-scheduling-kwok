import csv

class CsvWriter:
    def __init__(self, metrics_handler):
        self.metrics_handler = metrics_handler

    def write(self, filename):
        metrics = self.metrics_handler.read_metrics()

        print('Requesting data from Prometheus')
        results, labels = self.metrics_handler.get_results(metrics)

        print(f'Writing file {filename}')
        with open(filename, "w") as f:
            writer = csv.writer(f)

            # Write header
            writer.writerow(["name", "timestamp", "value"] + list(labels))

            for result in results:
                for values in result["values"]:
                    # print(values)
                    timestamp = values[0]
                    value = values[1]
                    l = [result["metric"].get("__name__", ""), timestamp, value]
                    for label in labels:
                        x = result["metric"].get(label, "")
                        l.append(x)
                    writer.writerow(l)