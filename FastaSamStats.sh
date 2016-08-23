echo "Suggested alignment files in current working directory: "
ls *.sam
echo "---"
#/scratch/beegfs/monthly/aechchik/MSc/minion/alignment/blasr/sam/r7_2d_blasr.sam
# enter your file
echo "Input the alignment file of your choice (.sam), followed by [ENTER]:"
read samfile
echo "---"

echo "Input path to alignment file, followed by [ENTER]:"
read sampath
echo "---"

#!/bin/bash
echo "Suggested fasta files in current working directory: "
ls *.fasta
echo "---"
#/scratch/beegfs/monthly/aechchik/MSc/minion/reads/r7_2d-only.fasta
# enter your file
echo "Input the fasta file of your choice (.fasta or .fa), followed by [ENTER]:"
read fastafile
echo "---"
echo "Input path to fasta file, followed by [ENTER]:"
read fastapath
echo "---"


# print read length next to mapped fragment  in the final stats file

awk 'FNR==NR{a[$1]=$4;next} ($1 in a) {print $0,a[$1],$2}'  $sampath$samfile'_FinalStats' $fastapath$fastafile'_ReadNameLength' | awk '{print $1,$2,$3}'  > $sampath$fastafile'_MappedReadLength' 

# get the mapped fragment length, divide it to the the whole read length => percentage of mapped reads 
cat $sampath$fastafile'_MappedReadLength' | awk '!$3 {exit ; }  {print $1, $3/$2 }' > $sampath$fastafile'_MappedReadPerc'

# how many reads map to how many fragments? check how many occurrences of the same ID in $1 
cat $sampath$fastafile'_MappedReadPerc' | awk '{print $1}' | sort | uniq -c > $sampath$fastafile'_NumberOfMapsPerRead'

