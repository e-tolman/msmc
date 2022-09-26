#!/bin/sh

#SBATCH --time=24:00:00   # walltime
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=20600M   # memory per CPU core
#SBATCH -J "bootstrap"   # job name
#SBATCH --mail-user=ethan.tolman@gmail.com   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

source ~/.bashrc
conda activate msmc

cd ../plot

rm plot.py
echo "#!/usr/bin/env python3

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

mu=3.4e-9
gen=5

msmc_out=pd.read_csv(\"combined.final.txt\", sep = \"\\t\", header=0)

t_years=gen * ((msmc_out.left_time_boundary + msmc_out.right_time_boundary)/2)/mu
plt.figure(figsize=(8,10))
plt.subplot(211)" >> plot.py


head -1 combined_boot_10.final.txt > combined.final.txt
for i in {2..28}
do
	left_time_boundary=$(awk '{ total += $2; count++ } END { print total/count }' row_$i.txt)
	right_time_boundary=$(awk '{ total += $3; count++ } END { print total/count }' row_$i.txt)
	lambda_00=$(awk '{ total += $4; count++ } END { print total/count }' row_$i.txt)
	lambda_01=$(awk '{ total += $5; count++ } END { print total/count }' row_$i.txt)
	lambda_11=$(awk '{ total += $6; count++ } END { print total/count }' row_$i.txt)
	time_index="$(($i-2))"
	echo "$time_index	$left_time_boundary	$right_time_boundary	$lambda_00	$lambda_01	$lambda_11" >> combined.final.txt

done

for i in {1..30}
do
	x=$(ls combined_boot_$i.final.txt | wc -l)
	if [ $x -gt 0 ]
	then
		echo "boot_out=pd.read_csv(\"combined_boot_$i.final.txt\", sep = \"\\t\", header=0)" >> plot.py
		echo "plt.semilogx(t_years,(1/boot_out.lambda_00)/(2*mu), drawstyle = 'steps', color='lightskyblue')" >> plot.py
		echo "plt.semilogx(t_years,(1/boot_out.lambda_11)/(2*mu), drawstyle = 'steps', color='lightcoral')" >> plot.py
	else
		echo "combined_boot_$i.final.txt has been removed"
	fi
done

echo "plt.semilogx(t_years,(1/msmc_out.lambda_00)/(2*mu), drawstyle = 'steps', color='darkblue', label='Pondosa')" >> plot.py
echo "plt.semilogx(t_years,(1/msmc_out.lambda_11)/(2*mu), drawstyle = 'steps', color='darkred', label='Cherry Hill')" >> plot.py

echo "plt.xlabel(\"years ago\")
plt.ylabel(\"population size\")
plt.legend()
plt.subplot(212)" >> plot.py


for i in {1..30}
do
	x=$(ls combined_boot_$i.final.txt | wc -l)
        if [ $x -gt 0 ]
        then
        	echo "boot_out=pd.read_csv(\"combined_boot_$i.final.txt\", sep = \"\\t\", header=0)" >> plot.py
		echo "relativeCCR=2.0 * boot_out.lambda_01 / (boot_out.lambda_00 + boot_out.lambda_11)" >> plot.py
		echo "plt.semilogx(t_years,relativeCCR, drawstyle='steps', color='lightskyblue')" >> plot.py
	else
		 echo "combined_boot_$i.final.txt has been removed"
	fi

done

echo "relativeCCR=2.0 * msmc_out.lambda_01 / (msmc_out.lambda_00 + msmc_out.lambda_11)" >> plot.py
echo "plt.semilogx(t_years,relativeCCR, drawstyle='steps', color='darkblue')" >> plot.py
echo "plt.xlabel(\"years ago\")
plt.ylabel(\"Relative CCR\")
plt.savefig(\"MSMC_plot.pdf\")" >> plot.py

python3 plot.py

