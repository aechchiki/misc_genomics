#!/bin/bash

# for coverage calculations, need: 
# 1) median sequenced read length
# 2) total number of sequenced reads
# 3) reference size

echo "Suggested fasta files in current working directory: "
ls *.fasta

# enter sequencing file
echo "Requiring the file containing sequencing reads. Input the file of your choice (fasta format required), followed by [ENTER]:"
read readsfile
echo "Input path to the previously chosen file (no need to specify if same as current directory), followed by [ENTER]:"
read readspath

# enter reference file (e.g. transcriptome)
echo "Requiring the file containing the reference sequence. Input the file of your choice (fasta format required), followed by [ENTER]:"
read reffile
echo "Input path to the previously chosen file (no need to specify if same as current directory), followed by [ENTER]:"
read refpath

# count how many sequenced reads in the inout sequence file
echo "Calculating number of reads in the input sequencing file..."
ReadsNumber=$(cat $readspath$readsfile | grep '^>' | wc -l)
echo "There are $ReadsNumber reads in the input sequencing file."

# count the median read lenght in the input sequencing file
echo "Generating read length in the input sequencing file..."
cat $readspath$readsfile | grep -v '^>' | awk '{ print length($0); }' > tmp_ReadsLen
echo "Calculating median of read length in input sequencing file..."
ReadsMedian=$(cat tmp_ReadsLen | sort -n | awk ' { a[i++]=$1; } END { print a[int(i/2)]; }')
echo "The median of the input read length is $ReadsMedian ."

# count reference length
echo "Calculating number of nucleotides in the input reference file..."
# remove all headers and newlines
cat $refpath$reffile | grep -v '^>' | awk '/^>/{print s? s"\n"$0:$0;s="";next}{s=s sprintf("%s",$0)}END{if(s)print s}' > tmp_CleanRef
# calculate character length
RefLen=$(cat tmp_CleanRef | awk '{ print length($1); }')
echo "The reference is $RefLen nucleotides long."

# compute rough coverage estimation
echo "Computing coverage..."
# coverage: medianReadLength* nbSequencedReads / totReflength
CoverageNum=$(($ReadsNumber * $ReadsMedian))
CoverageDen=$(($RefLen))
Coverage=$(($CoverageNum/CoverageDen))
echo "The coverage of the dataset is estimated to $Coverage X."

# print coverage to file
echo "Printing the coverage to file..."
echo "Select the name of the output file, followed by [ENTER]:"
read outCoverageFile
echo "Select the path to the output file, followed by [ENTER]:"
read outCoveragePath
# initialize coverage file
touch $outCoveragePath$outCoverageFile
# print variable to file
echo "$Coverage" >> $outCoveragePath$outCoverageFile

# finalize 
echo "The coverage is saved in $outCoveragePath$outCoverageFile ."
# removing tmp files
rm tmp_*
echo "Done. Exiting."
