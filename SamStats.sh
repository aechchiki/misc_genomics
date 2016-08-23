#!/bin/bash
echo "Suggested alignment files in current working directory: "
ls *.sam
echo "---"

# enter your file
echo "Input the alignment file of your choice (.sam), followed by [ENTER]:"
read samfile
echo "---"

# reads
echo "Counting the reads..."
cat $samfile | grep -v ^@ | wc -l > $samfile'_ReadsNumber'
echo "Done. Output written to: $samfile'_ReadsNumber'"
echo "---"

# nb of reads per bitwise flag
echo "Counting the reads per bitwise flag..."
cat $samfile | grep -v ^@ | awk '{ print $2 }' | sort | uniq -c > $samfile'_ReadsPerFlag'
echo "Done. Output written to: $samfile'_ReadsPerFlag'"
echo "---"

# read name
echo "Getting read names..."
cat $samfile | grep -v ^@ | awk '{ print $1 }' > $samfile'_ReadsName'
echo "Done. Output written to : $samfile'_ReadsName'"
echo "Getting read bitwise flags..."
cat $samfile | grep -v ^@ | awk '{ print $2 }' > $samfile'_ReadsFlag'
echo "Done. Output written to : $samfile'_ReadsFlag'"
echo "Getting map ID..."
cat $samfile | grep -v ^@ | awk '{ print $3 }' > $samfile'_ReadsID'
echo "Done. Output written to : $samfile'_ReadsID'"
echo "---"

# mapping quality 
echo "Getting the number of reads per mapping quality score..."
cat $samfile | grep -v ^@ | awk '{ print $5 }' | sort -n | uniq -c > $samfile'_ReadsMappingScore'
echo "Done. Output written to: $samfile'_ReadsMappingScore'"
echo "---"

# error rate 
echo "Parsing CIGAR line..."
cat $samfile | grep -v ^@ | awk '{ print $6 }' | sed 's/M/M /g' | sed 's/I/I /g' | sed 's/D/D /g' > $samfile'_ReadsCigar'
# insertion
echo "1. Generating insertion count per read..."
cat $samfile'_ReadsCigar' | sed 's/[0-9]*[!N]//g' | sed 's/[0-9]*[!S]//g' | sed 's/[0-9]*[!H]//g'| sed 's/[0-9]*[!P]//g' | sed 's/[0-9]*[!\=]//g' | sed 's/[0-9]*[!X]//g' | sed 's/[0-9]*[!D]//g' | sed 's/[0-9]*[!M]//g' | sed 's/I//g'| awk '{c=0;for(i=1;i<=NF;++i){c+=$i};print c, "Cigar: ", $0}' > $samfile'_InsertionPerRead'
# deletion
echo "2. Generating deletion count per read..."
cat $samfile'_ReadsCigar' | sed 's/[0-9]*[!N]//g' | sed 's/[0-9]*[!S]//g' | sed 's/[0-9]*[!H]//g'| sed 's/[0-9]*[!P]//g' | sed 's/[0-9]*[!\=]//g' | sed 's/[0-9]*[!X]//g' | sed 's/[0-9]*[!I]//g' | sed 's/[0-9]*[!M]//g' | sed 's/D//g'| awk '{c=0;for(i=1;i<=NF;++i){c+=$i};print c, "Cigar: ", $0}' > $samfile'_DeletionPerRead'
# mismatch
echo "3. Generating mismatch count per read..."
cat $samfile'_ReadsCigar'  | sed 's/[0-9]*[!N]//g' | sed 's/[0-9]*[!S]//g' | sed 's/[0-9]*[!H]//g'| sed 's/[0-9]*[!P]//g' | sed 's/[0-9]*[!\=]//g' | sed 's/[0-9]*[!X]//g' | sed 's/[0-9]*[!D]//g' | sed 's/[0-9]*[!I]//g' | sed 's/M//g'| awk '{c=0;for(i=1;i<=NF;++i){c+=$i};print c, "Cigar: ", $0}' > $samfile'_MismatchPerRead'
echo "---"

# get info from cigar line 
echo "Analyzing CIGAR line... "
# insertion
echo "1. Extracting insertion count per read..."
cat $samfile'_InsertionPerRead' | awk '{print $1}' > $samfile'_Insertions'
# deletion
echo "2. Extracting deletion count per read..."
cat $samfile'_DeletionPerRead' | awk '{print $1}' > $samfile'_Deletions'
# mismatch
echo "3. Extracting mismatch count per read..."
cat $samfile'_MismatchPerRead' | awk '{print $1}' > $samfile'_Mismatches'
echo "---"

# get mapped length
echo "Getting mapped segment length..."
cat $samfile | grep -v ^@ | awk '{ print $10 }' | awk '{ print length($0); }' > $samfile"_MapLength"
# insertion
echo "1. Getting insertion count per read..."
paste $samfile"_Insertions" $samfile"_MapLength" | awk '!$2 {exit ; }  {printf "%f\n",$1/$2 } ' > $samfile"_InsMap"
echo "Done. Output written to: $samfile_'InsMap'"
# deletion
echo "2. Getting deletion count per read..."
paste $samfile"_Deletions" $samfile"_MapLength" | awk '!$2 {exit ; }  {printf "%f\n",$1/$2 } ' > $samfile"_DelMap"
echo "Done. Output written to: $samfile'_DelMap'"
# mismatch
echo "3. Getting mismatch count per read..."
paste $samfile"_Mismatches" $samfile"_MapLength" | awk '!$2 {exit ; }  {printf "%f\n",$1/$2 } ' > $samfile"_MisMap"
echo "Done. Output written to: $samfile'_MisMap'"
echo "---"

echo "Getting reads stats..."
paste $samfile'_ReadsName' $samfile'_ReadsFlag' $samfile'_ReadsID' $samfile"_MapLength" $samfile"_InsMap" $samfile'_DelMap' $samfile'_MisMap' > $samfile'_FinalStats'
echo "Done. Output written to $samfile'_FinalStats'"
