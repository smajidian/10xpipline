#!/bin/bash

fragpoly='/mnt/LTR_userdata/majid001/software/code_py/FragmentPoly.py' # python2
sdhap='/mnt/LTR_userdata/majid001/software/sdhap/hap_poly'
split_molec='/mnt/LTR_userdata/majid001/software/code_py/split_v3b.py'
ConvertAllelesSDhaP='/mnt/LTR_userdata/majid001/software/code_py/ConvertAllelesSDhaP.py' # python2



cd $1  &&
k=$2   &&
cd frb   &&
python3 $split_molec frag.txt pos_freebayes.txt 50   &&
cd ..   
mkdir sdhap;  cp frb/frag_sp.txt sdhap; cd sdhap 
python2 $fragpoly -f frag_sp.txt  -o frag_sd.txt -x SDhaP   &&
$sdhap frag_sd.txt  out_sd_raw.hap  $k   &&

python2 $ConvertAllelesSDhaP -p out_sd_raw.hap -o haplotype.hap -v ../frb/var_het.vcf 


pwd

