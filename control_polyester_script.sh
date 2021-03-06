#!/usr/bin/env bash

#This script creates a simulated counts matrix and fasta file for simulation transcriptome.
#It also calculate TPM values and rename 'Gene1', 'Gene2' etc with isoform names.
/software/R-3.4.2/bin/Rscript format_counts.R
mkdir Simulation/data/sim_bias

END=`head -n1 raw_results/data/simulated_counts.txt | wc -w`

#Run polyester simulations, one for each splatter simulated cell
for i in $(seq 1 $END);
do
   /software/R-3.4.2/bin/Rscript make_polyester.R $i
done
