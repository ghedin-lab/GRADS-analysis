#!/bin/bash
#PBS -l walltime=160:00:00,nodes=1:ppn=20,mem=32gb
#PBS -M kmg549@nyu.edu
#PBS -m ae
#PBS -j oe

# run it like this: qsub -v fastq=samplename filter.sh
# modufy path, exec_path, and '.gz' extension if need be

module load deconseq
module load prinseq
module load sortmerna
module load biopython

# change this to where your fastq files are
path="/scratch/kmg549/grads/set02/rna"
cd $path

#fastq="test"

# set this to the directory where the custom python scripts are located. Will hopefully automate this later
exec_path="/scratch/at120/shared/laura-alan/2015-10-01_C68Y0ACXX-redo/new-filter/human-16s-filter"

# make sure the fastq files have the naming scheme "sample-name.r1.fastq.gz"
# these can be uncompressed as well, just remove the .gz below if they are
python $exec_path/interleave-fastq.py $fastq.r1.fastq $fastq.r2.fastq > $fastq.interleaved.fastq

# command used to index provided rRNA dbs indexdb_rna -m 30000 --ref rfam-5.8s-database-id98.fasta,rfam-5.8s-database-id98.db:rfam-5s-database-id98.fasta,rfam-5s-database-id98.db:silva-arc-16s-id95.fasta,silva-arc-16s-id95.db:silva-arc-23s-id98.fasta,silva-arc-23s-id98.db:silva-bac-16s-id90.fasta,silva-bac-16s-id90.db:silva-bac-23s-id98.fasta,silva-bac-23s-id98.db:silva-euk-18s-id95.fasta,silva-euk-18s-id95.db:silva-euk-28s-id98.fasta,silva-euk-28s-id98.fasta

sortDB="/scratch/at120/shared/db/human-16s-for-filtering/sortmerna-db"

sortmerna \
--otu_map \
-a 20 \
-m 4096 \
--sam \
--paired_in \
--aligned $fastq.rRNA \
--other $fastq.non-rRNA \
--fastx \
--de_novo_otu \
--log \
--reads $fastq.interleaved.fastq \
--ref \
$sortDB/rfam-5.8s-database-id98.fasta,$sortDB/rfam-5.8s-database-id98.db:\
$sortDB/rfam-5s-database-id98.fasta,$sortDB/rfam-5s-database-id98.db:\
$sortDB/silva-arc-16s-id95.fasta,$sortDB/silva-arc-16s-id95.db:\
$sortDB/silva-arc-23s-id98.fasta,$sortDB/silva-arc-23s-id98.db:\
$sortDB/silva-bac-16s-id90.fasta,$sortDB/silva-bac-16s-id90.db:\
$sortDB/silva-bac-23s-id98.fasta,$sortDB/silva-bac-23s-id98.db:\
$sortDB/silva-euk-18s-id95.fasta,$sortDB/silva-euk-18s-id95.db:\
$sortDB/silva-euk-28s-id98.fasta,$sortDB/silva-euk-28s-id98.db

#command to index deconseq db: bwa64 index -a bwtsw hg19-silva_16s-phix.fasta

# deconseq doesn't handle paired end data so this will be run last?
# deconseq.pl -f $fastq.non-rRNA.fastq 

# hg_phix for just human and phix (non-RNA-Seq data)
perl /scratch/at120/apps/deconseq-standalone-0.4.3/deconseq.pl -id $fastq.non-rRNA.deconseq -f $fastq.non-rRNA.fastq -dbs hg_phix_16s

mv $fastq.non-rRNA.deconseq_clean.fq $fastq.non-rRNA.deconseq_clean.fastq

python $exec_path/extract-paired-reads-from-one-file.py $fastq.non-rRNA.deconseq_clean.fastq $fastq.non-rRNA.deconseq_clean

:<< 'END'
prinseq-lite.pl \
-fastq $fastq.non-rRNA.deconseq_clean.fastq \
-out_format 3 \
-out_good $fastq.non-rRNA.deconseq_clean.prinseq_good \
-out_bad $fastq.non-rRNA.deconseq_clean.prinseq_bad \
-lc_threshold 15 \
-lc_method dust \
-no_qual_header \
-range_len 50,300 \
-min_qual_mean 25 \
-ns_max_p 10 \
-derep 12 \
-trim_qual_right 20 \
-trim_qual_type min  \
-trim_qual_window 1 \
-trim_qual_step 1 \
-trim_qual_rule lt
#-stats_all > $fastq.non-rRNA.deconseq_clean.prinseq.stats.txt

python $exec_path/extract-paired-reads-from-one-file.py $fastq.non-rRNA.deconseq_clean.prineq_good.fastq
END
