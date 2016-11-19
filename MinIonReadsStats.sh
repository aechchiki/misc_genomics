#!/bin/bash
echo "Suggested fastq files in current working directory: "
ls *.fastq
echo "---"

# enter your file
echo "Input the fastq file of your choice (.fastq or .fq), followed by [ENTER]:"
read fastqfile
echo "---"

# print read length
echo "Total read count: "
tot=$(cat $fastqfile | grep ^@ | wc -l )
echo "$tot"

echo "2D reads count: " 
twod=$(cat $fastqfile | grep ^@ | grep '_2d' | wc -l)
echo "$twod"
echo "Proportion of 2D reads:" ; bc -l <<< $twod/$tot

echo "Template read count: "
template=$(cat $fastqfile | grep ^@ | grep '_template' | wc -l)
echo "$template"
echo "Proportion of template reads:" ; bc -l <<<  $template/$tot

echo "Complement read count: "
complement=$(cat $fastqfile | grep ^@ | grep '_complement' | wc -l)
echo "$complement"
echo "Proportion of complement reads:"; bc -l <<< $complement/$tot
