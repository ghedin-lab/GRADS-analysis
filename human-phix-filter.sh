#!/bin/bash
#PBS -l walltime=100:00:00,nodes=1:ppn=20,mem=180gb
#PBS -M kmg549@nyu.edu
#PBS -m ae
#PBS -j oe

# run it like this: qsub -v fastq=samplename filter.sh
# modufy path, exec_path, and '.gz' extension if need be

module load deconseq
module load prinseq
module load biopython

# change this to where your fastq files are
path="/scratch/kmg549/grads/set02/dna"
cd $path

#fastq="test"

# set this to the directory where the custom python scripts are located. Will hopefully automate this later
exec_path="/scratch/at120/shared/laura-alan/2015-10-01_C68Y0ACXX-redo/new-filter/human-16s-filter"

# make sure the fastq files have the naming scheme "sample-name.r1.fastq.gz"
# these can be uncompressed as well, just remove the .gz below if they are
python $exec_path/interleave-fastq.py $fastq.r1.fastq $fastq.r2.fastq > $fastq.interleaved.fastq

#command to index deconseq db: bwa64 index -a bwtsw hg19-silva_16s-phix.fasta

perl /scratch/at120/apps/deconseq-standalone-0.4.3/deconseq.pl -id $fastq.interleaved.deconseq -f $fastq.interleaved.fastq -dbs hg_phix

mv $fastq.interleaved.deconseq_clean.fq $fastq.interleaved.deconseq_clean.fastq

python $exec_path/extract-paired-reads-from-one-file.py $fastq.interleaved.deconseq_clean.fastq $fastq.interleaved.deconseq_clean

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
