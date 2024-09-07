import pandas as pd
import glob
import os

# Directory containing the CSV files
directory = "../output/real-two-minutes/"

print ("\t\tCPU\t\t\tMEM")
print ("Experiment\tMax\tAvg\tMedian\tMax\tAvg\tMedian")
# Iterate over all files ending with "-cost.csv"
for file in glob.glob(f"{directory}*-cost.csv"):
    # Read the CSV file
    df = pd.read_csv(file)
    
    # Calculate statistics for CPU%
    cpu_max = df['CPU%'].max()
    cpu_avg = df['CPU%'].mean()
    cpu_median = df['CPU%'].median()
    
    # Calculate statistics for MEM%
    mem_max = df['MEM%'].max()
    mem_avg = df['MEM%'].mean()
    mem_median = df['MEM%'].median()
    
    print (os.path.basename(file) + " " + "{:.2f}\t{:.2f}\t{:.2f}\t{:.2f}\t{:.2f}\t{:.2f}".format(cpu_max, cpu_avg, cpu_median, mem_max, mem_avg, mem_median))
    print()