#!/bin/bash
#PBS -N TE_CERVIX
#PBS -l nodes=1:ppn=10
#PBS -l walltime=1000:00:00
#PBS -j oe
#PBS -q fat
name="CERVIX"
data_dir="/histor/sun/huangjunsong/raw_data/CCLE"
work_dir="/histor/sun/huangjunsong/analysis_data/CCLE/CERVIX"
ref_dir="/histor/sun/huangjunsong/reference"
soft_dir="/histor/sun/huangjunsong/software/TEtranscripts/bin"

mkdir ${data_dir}/${name}/TEtranscripts_results
mkdir ${data_dir}/${name}/TElocal_results
cd ${data_dir}/${name}/fastq_data
for SAMPLE in `ls -lh *.gz | awk '{print $9}' |  awk '{print substr($0,1,length($0)-11)}' | uniq | tr -d '\\r'` 
do
#TIME
echo "~~~~ start working ~~~~~"
date
date
date

#TEcount
${soft_dir}/TEcount \
-b ${data_dir}/${name}/map_data/${SAMPLE}Aligned.sortedByCoord.out.bam \
--GTF ${ref_dir}/GENCODE.Homo.GRCh38.gtf --TE ${ref_dir}/GENCODE_GRCh38_rmsk_TE.gtf \
--outdir ${data_dir}/${name}/TEtranscripts_results/ --project ${SAMPLE} --sortByPos

#TElocal
cd ${data_dir}/${name}/TElocal_results
TElocal \
-b ${data_dir}/${name}/map_data/${SAMPLE}Aligned.sortedByCoord.out.bam \
--GTF ${ref_dir}/GENCODE.Homo.GRCh38.gtf --TE ${ref_dir}/GENCODE_GRCh38_rmsk_TE.gtf.locInd \
--project ${SAMPLE} --sortByPos
done
