#!/usr/bin/env bash

#Create simulated counts matrix and fastq file for simulation transcriptome
#/software/R-3.4.2/bin/Rscript format_counts.R
mkdir Simulation/data/sim_bias

END=`head -n1 raw_results/data/simulated_counts.txt | wc -w`

#Run polyester simulations, one for each splatter simulated cell
for i in $(seq 1 $END);
do
  bsub -R"span[hosts=1]" -c 99999 -G team_hemberg -q normal -o $TEAM/temp.logs/output.polyester$i -e $TEAM/temp.logs/error.polyester$i -R"select[mem>100000] rusage[mem=100000]" -M 100000 /software/R-3.4.2/bin/Rscript make_polyester.R $i
done
