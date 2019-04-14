#!/bin/bash
outdir=thale_cress_assembly
datapath=/usr/share/data/proj_data/thale_cress
mkdir $outdir
cd $outdir
Nanoplot --fastq $datapath/ERR2173373.fastq.gz --outd nanoplot_thale_cress
# Nanoplot 

#nanofilt? cut off quality @ 7 grep the @ for starting file and filtered file
#Filtering

#Run Canu
canu -p thale-cress0 -d canucress genomeSize=135m maxMemory=80g maxThreads=16 -nanopore-raw $datapath/ERR2173373.fastq.gz > logcanu0

#Racon long read polishing

