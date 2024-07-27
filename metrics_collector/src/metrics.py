import requests
from datetime import datetime, timedelta

class Metrics:
    def __init__(self, metrics_filepath, prometheus_host, scrape_interval):
        self.metrics_filepath = metrics_filepath
        self.prometheus_host = prometheus_host
        self.scrape_interval = scrape_interval


    def read_metrics(self):
        with open(self.metrics_filepath, "r") as f:
            metrics = [line.strip() for line in f]

        return metrics

    def request_metrics(self, metric, start, end, step):
        response = requests.get(
            f"{self.prometheus_host}/api/v1/query_range",
            params = {
                "query": metric,
                "start": start,
                "end": end,
                "step": step
                },
            )
        return response

    def get_results(self, metrics):
        results = []
        labels = set()
        # end is the current time with the format of Unix timestamp
        end = int(datetime.timestamp(datetime.now()))
        # start is the current time minus one hour with the format of Unix timestamp
        start = end - 4200

        for metric in metrics:
            response = self.request_metrics(metric, start, end, self.scrape_interval)
            try:
                response_results = response.json()["data"]["result"]
            except KeyError:
                print(f"Error: {response.json()}")
                continue
            
            for r in response_results:
                if len(r) > 0:
                    results.append(r)
                    labels.update(r["metric"].keys())

        if "__name__" in labels:
            labels.remove("__name__")

        return results, labels