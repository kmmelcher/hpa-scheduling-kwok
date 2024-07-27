import os, time, sys, time, shutil
from datetime import datetime
from csv_writer import CsvWriter
from metrics import Metrics

def main():  
    if len(sys.argv) != 6:
        print("Usage: main.py <metrics_filepath> <prometheus_host> <scrape_interval> <output_dir> <experiment_name>")
        sys.exit(1)

    metrics_filepath, prometheus_host, scrape_interval, output_dir, experiment_name = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]  
    metrics = Metrics(metrics_filepath, prometheus_host, scrape_interval)

    writer = CsvWriter(metrics)

    dirname = output_dir
    if not os.path.exists(dirname):
        os.mkdir(dirname)
        
    filename = f"{dirname}/{experiment_name}.csv"

    print(f'Writing file {filename}')
    writer.write(filename)          
        
if __name__ == "__main__":
    main()
