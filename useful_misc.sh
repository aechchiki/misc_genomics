# modules on vital-IT
module add UHTS/Analysis/seqtk/2015.10.15;
module add UHTS/Analysis/samtools/1.3;
module add R/3.2.2;
module add UHTS/Aligner/BBMap/32.15;
module add UHTS/Analysis/picard-tools/2.2.1;
module add UHTS/Assembler/cufflinks/2.2.1; 

# fastq to fasta 
seqtk seq -a in.fastq.gz > out.fasta

# convert bam to sam 
samtools view -h -o out.sam in.bam
# convert sam to bam 
samtools view -Sb in.sam > out.bam
