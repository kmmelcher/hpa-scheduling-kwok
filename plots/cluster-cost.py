import pandas as pd
import glob
import os
from dotenv import load_dotenv

load_dotenv(dotenv_path='../.env')

directory = "../output/" + os.getenv("OUTPUT_DIR")

cpus = 10

print ("\t\tCPU\tMEM")
print ("Experiment")

for file in glob.glob(f"{directory}/*-cost.csv"):
    data = pd.read_csv(file)

    cpu_avg = data['CPU%'].mean() / cpus
    mem_avg = data['MEM%'].mean()
    
    print (os.path.basename(file) + " " + "{:.2f}\t{:.2f}".format(cpu_avg, mem_avg))
    print()