#!/bin/bash
echo "Suggested fasta files in current working directory: "
ls *.fasta
echo "---"

# enter your file
echo "Input the fasta file of your choice (.fasta or .fa), followed by [ENTER]:"
read fastafile
echo "---"

# print read length
echo "Getting reads name..."
cat $fastafile | grep '^>' | cut -d " " -f1 | sed 's/>//' > $fastafile'_ReadName'
echo "Getting reads length..."
cat $fastafile | grep -v '^>' | awk '{ print length($0); }' > $fastafile'_ReadLength'

# print some statistics
echo "Getting number of reads in fasta file..."
cat $fastafile'_ReadLength' | wc -l >  $fastafile'_ReadNumber'
echo "Getting mean of read length..."
cat $fastafile'_ReadLength' | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n; }' > $fastafile'_MeanReadLength'
echo "Getting standard deviation of read length..."
cat $fastafile'_ReadLength' | awk '{ sum += $1; array[NR] = $1 } END { for ( x=1; x <= NR; x++ ){ sumsq += (( array[x] - (sum/NR))**2); } print sqrt( sumsq/NR)}' > $fastafile'_SdReadLength'
echo "Getting median of read length..."
cat $fastafile'_ReadLength' | sort -n | awk ' { a[i++]=$1; } END { print a[int(i/2)]; }' > $fastafile'_MedianReadLength'
echo "Getting minimum read length..."
cat $fastafile'_ReadLength' | awk 'BEGIN { a=1000 } { if ($1 < 0+a ) a=$1 } END { print a }' > $fastafile'_MinReadLangth'
echo "Getting maximum read length..."
cat $fastafile'_ReadLength' | awk 'BEGIN { a=0 } { if ( $1 > 0+a ) a=$1 } END { print a }'> $fastafile'_MaxReadLength'

# write to output
paste $fastafile'_ReadNumber' $fastafile'_MeanReadLength' $fastafile'_SdReadLength' $fastafile'_MedianReadLength' $fastafile'_MinReadLangth' $fastafile'_MaxReadLength' > $fastafile'_ReadStatsTable'
echo -e "ReadNumber\tMeanReadLength\tSdReadLength\tMedianReadLength\tMinReadLangth\tMaxReadLength"
echo "Done. Output written to $fastafile'_ReadStatsTable'"
