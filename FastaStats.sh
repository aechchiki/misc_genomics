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
echo "Printing reads name and length..."
paste $fastafile'_ReadName' $fastafile'_ReadLength' > $fastafile'_ReadNameLength'
echo "Done. Output written to $fastafile'_ReadNameLength'"
echo "---"
