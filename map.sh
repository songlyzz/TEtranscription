#!/bin/bash
#PBS -N CERVIX_map
#PBS -l nodes=1:ppn=10
#PBS -l walltime=1000:00:00
#PBS -j oe
#PBS -q fat
name="CERVIX"
data_dir="/histor/sun/huangjunsong/raw_data/CCLE"
work_dir="/histor/sun/huangjunsong/analysis_data/CCLE/CERVIX"
ref_dir="/histor/sun/huangjunsong/reference"
THREADS=8
mkdir ${data_dir}/${name}/qc_data
mkdir ${data_dir}/${name}/qc_data/reports
mkdir ${data_dir}/${name}/map_data
cd ${data_dir}/${name}/fastq_data

source activate RNAseq
for SAMPLE in `ls -lh *.gz | awk '{print $9}' |  awk '{print substr($0,1,length($0)-11)}' | uniq | tr -d '\\r'` 
do
#TIME
echo "~~~~ start working ~~~~~"
date
date
date

#quality control
fastp \
-w ${THREADS} \
-i ${data_dir}/${name}/fastq_data/${SAMPLE}_1.fastq.gz -I ${data_dir}/${name}/fastq_data/${SAMPLE}_2.fastq.gz \
-o ${data_dir}/${name}/qc_data/QC_${SAMPLE}_1.fastq.gz -O ${data_dir}/${name}/qc_data/QC_${SAMPLE}_2.fastq.gz \
--html ${data_dir}/${name}/qc_data/reports/${SAMPLE}.html --json ${data_dir}/${name}/qc_data/reports/${SAMPLE}.json
echo "==========Quality controling============"

#mapping
STAR \
--runThreadN ${THREADS} \
--readFilesCommand zcat \
--outSAMtype BAM SortedByCoordinate \
--outSAMunmapped Within \
--outSAMattributes Standard \
--winAnchorMultimapNmax 100 --outFilterMultimapNmax 100 --outFilterMismatchNoverLmax 0.04 \
--genomeDir ${ref_dir}/STAR_GENCODE_GRCh38_index/ \
--readFilesIn ${data_dir}/${name}/qc_data/QC_${SAMPLE}_1.fastq.gz ${data_dir}/${name}/qc_data/QC_${SAMPLE}_2.fastq.gz \
--outFileNamePrefix ${data_dir}/${name}/map_data/${SAMPLE} \
--limitBAMsortRAM 43606184859
echo "=========Mapping ======================"

#index
cd ${data_dir}/${name}/map_data
samtools index ${SAMPLE}*sortedByCoord.out.bam
echo "~~~~ finish working ~~~~~"
done

conda deactivate
