#!/bin/bash
echo "Suggested alignment files: "
ls *.sam
# enter your file
echo "Input the alignment file of your choice (.sam), followed by [ENTER]:"
read samfile
echo "Input path to alignment file, followed by [ENTER]:"
read sampath

echo "Suggested fasta files in current working directory: "
ls *.fasta
# enter your file
echo "Input the fasta file of your choice (.fasta or .fa), followed by [ENTER]:"
read fastafile
echo "Input path to fasta file, followed by [ENTER]:"
read fastapath

echo "Input the output directory you want to write to, followed by [ENTER]:"
read outdir
mkdir -p $outdir


# l1
echo "Calculating input read length..."
# get read names 
cat $fastapath$fastafile | grep '^>' | sed 's/>//' | awk '{print $1}' > $outdir'FastaReadNames'
# get read length 
cat $fastapath$fastafile | grep -v '^>' | awk '{print length($0); }' > $outdir'FastaReadLength'
# merge read names and length
echo "Generating read name and length..."
paste $outdir'FastaReadNames' $outdir'FastaReadLength' > $outdir'FastaReadSpec'
echo "Done. Output written to $outdir'FastaReadSpec'"


# l2 
echo "Calculating input mapped read length, alignment type and quality..."
# get read mapped length
cat $sampath$samfile | grep -v '^@' | awk '{print $1, $2, $5}' > $outdir'SamReadSpec'
echo "Done. Output written to $outdir'SamReadSpec'"

# merge 
echo "Merging info read and alignment specs..."
join <(sort $outdir'FastaReadSpec') <(sort $outdir'SamReadSpec') > $outdir'ReadSpec'
echo "Done. Output written to $outdir'ReadSpec'"


# add info on  read match or mismatch, l3

echo "Parsing CIGAR line..."
cat $sampath$samfile | grep -v ^@ | awk '{ print $6 }' | sed 's/M/M /g' | sed 's/I/I /g' | sed 's/D/D /g' > $outdir'SamCigar'
cat $sampath$samfile | grep -v ^@ | awk '{print $1}' > $outdir'SamNames'
# 
echo "1. Generating insertion count per read..."
cat $outdir'SamCigar' | sed 's/[0-9]*[!N]//g' | sed 's/[0-9]*[!S]//g' | sed 's/[0-9]*[!H]//g'| sed 's/[0-9]*[!P]//g' | sed 's/[0-9]*[!\=]//g' | sed 's/[0-9]*[!X]//g' | sed 's/[0-9]*[!D]//g' | sed 's/[0-9]*[!M]//g' | sed 's/I//g'| awk '{c=0;for(i=1;i<=NF;++i){c+=$i};print c}' > $outdir$'CigarIns'
paste $outdir'SamNames' $outdir$'CigarIns' > $outdir'ReadNameCigarIns'

# deletion
echo "2. Generating deletion count per read..."
cat $outdir'SamCigar' | sed 's/[0-9]*[!N]//g' | sed 's/[0-9]*[!S]//g' | sed 's/[0-9]*[!H]//g'| sed 's/[0-9]*[!P]//g' | sed 's/[0-9]*[!\=]//g' | sed 's/[0-9]*[!X]//g' | sed 's/[0-9]*[!I]//g' | sed 's/[0-9]*[!M]//g' | sed 's/D//g'| awk '{c=0;for(i=1;i<=NF;++i){c+=$i};print c}' > $outdir$'CigarDel'
paste $outdir'SamNames' $outdir$'CigarDel' > $outdir'ReadNameCigarDel'

# alignment match
echo "3. Generating alignment match count per read..."
cat $outdir'SamCigar' | sed 's/[0-9]*[!N]//g' | sed 's/[0-9]*[!S]//g' | sed 's/[0-9]*[!H]//g'| sed 's/[0-9]*[!P]//g' | sed 's/[0-9]*[!\=]//g' | sed 's/[0-9]*[!X]//g' | sed 's/[0-9]*[!D]//g' | sed 's/[0-9]*[!I]//g' | sed 's/M//g'| awk '{c=0;for(i=1;i<=NF;++i){c+=$i};print c}' > $outdir$'CigarMat'
paste $outdir'SamNames' $outdir$'CigarMat' > $outdir'ReadNameCigarMat'

# mapped read length
echo "Calculating mapped read length (M+I)..."
join <(sort $outdir'ReadNameCigarMat') <(sort $outdir'ReadNameCigarIns') | awk '{print $1, ($2+$3)}' > $outdir'MapReadLength'

# reference length to which read hap been mapped
echo "Calculating reference length at mapping fragment (M+D)..."
join <(sort $outdir'ReadNameCigarMat') <(sort $outdir'ReadNameCigarDel') | awk '{print $1, ($2+$3)}' > $outdir'RefReadLength'

# perc alignment mtch read
echo "Calculating percentage of alignment match in mapped read length (M/M+I)..."
join <(sort $outdir'ReadNameCigarMat') <(sort $outdir'MapReadLength') | awk '{print $1, ($2/$3)}' > $outdir'AlnMatchPercRead'


# perc alignment mtch reference
echo "Calculating percentage of alignment match in mapped reference length (M/M+D)..."
join <(sort $outdir'ReadNameCigarMat') <(sort $outdir'RefReadLength') | awk '{print $1, ($2/$3)}' > $outdir'AlnMatchPercRef'

# perc alignment insertions read
echo "Calculating percentage of alignment match in mapped read length (I/M+I)..."
join <(sort $outdir'ReadNameCigarIns') <(sort $outdir'MapReadLength') | awk '{print $1, ($2/$3)}' > $outdir'AlnInsPercRead'


# perc alignment deletions reference
echo "Calculating percentage of alignment match in mapped reference length (D/M+D)..."
join <(sort $outdir'ReadNameCigarDel') <(sort $outdir'RefReadLength') | awk '{print $1, ($2/$3)}' > $outdir'AlnDelPercRef'


join <(sort $outdir'MapReadLength') <(sort  $outdir'RefReadLength' ) | join - <(sort $outdir'AlnMatchPercRead') | join - <(sort  $outdir'AlnMatchPercRef' ) | join - <(sort $outdir'AlnInsPercRead') | join - <(sort $outdir'AlnDelPercRef') > $outdir'AlnCalc'

# merge all info tgth
join <(sort $outdir'ReadSpec') <(sort $outdir'AlnCalc') > $outdir'AlnStats'

# mapped length to mapped read
echo "Calculating proportion of mapped length to the total read length... "
cat $outdir'AlnStats' | awk '{print $5/$2}' > $outdir'ReadAlnLen'
# mapped length to ref length
echo "Calculating proportion of mapped length to the reference length... "
cat $outdir'AlnStats' | awk '{print $5/$6}' > $outdir'ReadRefLen'

# add info on mismatch
join < (sort $outdir'AlnStats') < (sort $outdir'ReadAlnLen') | join - <(sort $outdir'ReadRefLen') > > $outdir'AlnStatsSpec'

