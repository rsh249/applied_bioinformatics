#!/bin/bash
outdir=thale_cress_assembly
datapath=/usr/share/data/proj_data/thale_cress
mkdir $outdir
cd $outdir

# Nanoplot 
Nanoplot --fastq $datapath/ERR2173373.fastq.gz --outd nanoplot_thale_cress


#cut off quality @ 7 grep the @ for starting file and filtered file
#Filtering
gunzip -c $datapath/ERR2173373.fastq.gz | NanoFilt -q 7 | gzip > highQuality-TCreads.fastq.gz

grep -c "@" /usr/share/data/proj_data/thale_cress/ERR2173373.fastq.gz
#9436354 
grep -c "@" highQuality-TCreads.fastq.gz
#9126407

#Nanostat
NanoStat -t 6 --fastq /usr/share/data_proj_data/thale_cress/ERR2173373.fastq.gz

#Run Canu using fastq file
canu -p thale-cress0 -d canucress genomeSize=135m maxMemory=80g maxThreads=16 -nanopore-raw $datapath/ERR2173373.fastq.gz > logcanu0



#Accessing References Genome
reads=$datapath/ERR2173373.fastq.gz
assembly=~/thale_cress_assembly/canucress/thale-cress0.contigs.fasta
mkdir polishcress
cd polishcress

#Quast: Genome stats and visualization

wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/plant/Arabidopsis_thaliana/reference/GCF_000001735.4_TAIR10.1/GCF_000001735.4_TAIR10.1_genomic.fna.gz
gunzip GCF_000001735.4_TAIR10.1_genomic.fna.gz
refdata=GCF_000001735.4_TAIR10.1_genomic.fna

quast.py $assembly -R $refdata --nanopore $reads -o quast_cress_output_base

#*to copy to computer 
##scp -r jcallahan@10.124.102.23:/home/jcallahan/thale_cress_assembly/polishcress/quast_cress_output_base ./

#For other assemblies, we will run quast for each of the racon polished references: 
quast.py ~/thale_cress_assembly/polishcress/mapIT01.fa -R $refdata --nanopore $reads -o quast01_cress_output_base
#ran in polishcress
quast.py ~/thale_cress_assembly/polishcress/mapIT02.fa -R $refdata --nanopore $reads -o quast02_cress_output_base

quast.py ~/thale_cress_assembly/polishcress/mapIT03.fa -R $refdata --nanopore $reads -o quast03_cress_output_base

#Polishing

#Iteration 1:
#Map reads to assembly using minimap:
minimap -Sw5 -L100 -m0 -t16 $assembly $reads > mapIT01.paf
##Where: + “-t2” specifies 2 threads (optional for this small example) + “Sw5” ????? + “-m0” specifies to never merge chains. + “-L100” requires matches to be at least 100 base pairs in length


#Then we take those mapped data and generate a consensus sequence over the assembly using racon.
racon -t 16 $reads mapIT01.paf $assembly > mapIT01.fa

#Iteration 2:
minimap -Sw5 -L100 -m0 -t16 mapIT01.fa $reads > mapIT02.paf
racon -t16 $reads mapIT02.paf mapIT01.fa > mapIT02.fa

#Iteration 3: 
minimap -Sw5 -L100 -m0 -t16 mapIT02.fa $reads > mapIT03.paf
racon -t16 $reads mapIT03.paf mapIT02.fa > mapIT03.fa


#Observing Differences using dnadiff

mkdir dnacress #(in polishcress folder)
dnadiff -p ref ../$refdata ~/thale_cress_assembly/canucress/thale-cress0.contigs.fasta

dnadiff -p one ../$refdata ../mapIT01.fa

dnadiff -p two ../$refdata ../mapIT02.fa

dnadiff -p three ../$refdata ../mapIT03.fa

#look at %Identity
grep "TotalSNPs" *.report

grep "TotalIndels" *.report


#Pilon polishing

cp $assembly ./

aslocal=thale-cress0.contigs.fasta #or name of assembly contigs

bwa index $aslocal #call local copy of assembly file by name here because bwa needs write access

bwa mem -t 4 $aslocal $reads | samtools view - -Sb | samtools sort - -@4 -o WGS.sorted.bam

samtools index WGS.sorted.bam

#grab pilon jar file

wget https://github.com/broadinstitute/pilon/releases/download/v1.23/pilon-1.23.jar

#run java pilon to control memory and thread use
java -Xmx256G -jar pilon-1.23.jar --genome $aslocal --fix all --changes --bam WGS.sorted.bam --threads 8 --outdir pilonpolish

ls -lh pilonpolish




#Gene prediction

##Prodigal gene prediction
prodigal.linux -i ~/thale_cress_assembly/canucress/thale-cress0.contigs.fasta -o prodigal.test -a proteins.faa

#went onto the GOFEAT website to annotate the proteins.faa file 
#uploaded csv file andread it into R

