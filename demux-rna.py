import os
import sys
import gzip
from Bio import SeqIO

bc = dict()

# make sure this file is in your working directory. You can grab it from github
with open("GRADS_randomized_samples_set02.txt","r") as f:
    for line in f:
        if "PLATE" in line:
            continue
        l=line.rstrip().rstrip().split("\t")
        dnabc = l[7]
        rnabc = l[10]

        if dnabc in bc:
            bc[dnabc]["dna"] = l[5]
        else:
            bc[dnabc] = dict()
            bc[dnabc]["dna"] = l[5]
            
        if rnabc in bc:
            bc[rnabc]["rna"] = l[8]
        else:
            bc[rnabc] = dict()
            bc[rnabc]["rna"] = l[8]
        
        bc[dnabc]["dnar1"] = open(bc[dnabc]["dna"]+"."+dnabc+".dna.r1.fastq","w")
        bc[dnabc]["dnar2"] = open(bc[dnabc]["dna"]+"."+dnabc+".dna.r2.fastq","w")
        bc[rnabc]["rnar1"] = open(bc[rnabc]["rna"]+"."+rnabc+".rna.r1.fastq","w")
        bc[rnabc]["rnar2"] = open(bc[rnabc]["rna"]+"."+rnabc+".rna.r2.fastq","w")

i = 0

def subFastq(seqObj,end):
    l = seqObj.format("fastq").rstrip().split("\n")
    l[1] = l[1][end:]
    l[3] = l[3][end:]
    l.append("\n")
    return "\n".join(l)
#return "\n".join([l,"\n"])

# change the fastq names accordingly
with open("HFWWMBGXY_n01_grads_set02_rna_digest_nextseq.fastq","r") as f1, open("unclassified.rna.r1.fastq","w") as u1, open("unclassified.rna.r2.fastq","w") as u2:
    f2 = SeqIO.parse(open("HFWWMBGXY_n02_grads_set02_rna_digest_nextseq.fastq","r"),"fastq")
    for r1 in SeqIO.parse(f1,"fastq"):
        # WTF IS THIS?!
        r2 = next(f2)

	# change rna1/2 to dna1/2. Can be configured in argparse
        if str(r1.seq[6:13]) in bc:
            bc[str(r1.seq[6:13])]["rnar1"].write(subFastq(r1,13))
            bc[str(r1.seq[6:13])]["rnar2"].write(subFastq(r2,13))
        elif str(r1.seq[5:12]) in bc:
            bc[str(r1.seq[5:12])]["rnar1"].write(subFastq(r1,12))
            bc[str(r1.seq[5:12])]["rnar2"].write(subFastq(r2,12))
            #print("5",bc[str(r1.seq[5:12])]["rna"],r1.seq[5:12],r1.seq[0:13])
        else:
            #print("NA",r1.seq[0:13])
            u1.write(r1.format("fastq"))
            u2.write(r2.format("fastq"))
            
"""        i += 1
        
        if i == 10:
            break
"""
for i in bc:
    for y in ["dnar1","dnar2","rnar1","rnar2"]:
        bc[i][y].close()
u1.close()
u2.close()

