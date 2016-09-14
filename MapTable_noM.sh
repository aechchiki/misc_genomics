#!/bin/bash
echo "Suggested alignment files: "
ls *.sam
# enter your file
echo "Input the alignment file of your choice (.sam), followed by [ENTER]:"
read samfile
echo "Input path to alignment file, followed by [ENTER]:"
read sampath
# TODO: add choice for bam files; call module samtools

# vital-it module:  module add UHTS/Analysis/samtools/1.3;
# to convert bam-sam: samtools view -h -o out.sam in.bam

# if input = sam, then proceed directlly,
# if input = bam, then convert first

echo "Suggested fasta files in current working directory: "
ls *.fasta
# enter your file
echo "Input the fasta file of your choice (.fasta or .fa), followed by [ENTER]:"
read fastafile
echo "Input path to fasta file, followed by [ENTER]:"
read fastapath
# TODO: add choice for fastq input

echo "Input the output directory you want to write to, followed by [ENTER]:"
read outdir
mkdir -p $outdir
# TODO: add warning to add the final directrory backslass 

# if fastq, convert first, or write a parser for filename 

# l1
echo "Calculating input read length..."
# get read names 
cat $fastapath$fastafile | grep '^>' | sed 's/>//' | awk '{print $1}' > $outdir'FastaReadNames'
# get read length 
cat $fastapath$fastafile | grep -v '^>' | awk '{print length($0); }' > $outdir'FastaReadLength'
# merge read names and length
echo "Generating read name and length..."
paste $outdir'FastaReadNames' $outdir'FastaReadLength' > $outdir'FastaReadSpec'


# l2 
echo "Calculating input mapped read length, alignment type and quality..."
# get read mapped length
cat $sampath$samfile | grep -v '^@' | awk ' BEGIN { FS = "\t" } ;{print $1, $2, $5}' > $outdir'SamReadSpec'

# merge 
echo "Merging info read and alignment specs..."
join <(sort -k 1b,1 $outdir'FastaReadSpec') <(sort -k 1b,1 $outdir'SamReadSpec') > $outdir'ReadSpec'


# add info on  read match or mismatch, l3

echo "Parsing CIGAR line..."
cat $sampath$samfile | grep -v ^@ | awk ' BEGIN { FS = "\t" } ;{print $6}' |  sed 's/N/N /g' | sed 's/S/S /g' | sed 's/H/H /g' | sed 's/P/P /g' | sed 's/=/= /g' |  sed 's/X/X /g' | sed 's/M/M /g' | sed 's/I/I /g' | sed 's/D/D /g' > $outdir'SamCigar'
cat $sampath$samfile | grep -v ^@ | awk ' BEGIN { FS = "\t" } ;{print $1}' > $outdir'SamNames'
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
echo "3.1 Generating non-identity match count per read..."
cat $outdir'SamCigar' | sed 's/[0-9]*[!N]//g' | sed 's/[0-9]*[!S]//g' | sed 's/[0-9]*[!H]//g'| sed 's/[0-9]*[!P]//g' | sed 's/[0-9]*[!\=]//g' | sed 's/[0-9]*[!M]//g' | sed 's/[0-9]*[!D]//g' | sed 's/[0-9]*[!I]//g' | sed 's/X//g'| awk '{c=0;for(i=1;i<=NF;++i){c+=$i};print c}' > $outdir$'CigarMatX'
paste $outdir'SamNames' $outdir$'CigarMatX' > $outdir'ReadNameCigarMatX'
echo "3.2 Generating identity match count per read..."
cat $outdir'SamCigar' | sed 's/[0-9]*[!N]//g' | sed 's/[0-9]*[!S]//g' | sed 's/[0-9]*[!H]//g'| sed 's/[0-9]*[!P]//g' | sed 's/[0-9]*[!X]//g' | sed 's/[0-9]*[!M]//g' | sed 's/[0-9]*[!D]//g' | sed 's/[0-9]*[!I]//g' | sed 's/=//g'| awk '{c=0;for(i=1;i<=NF;++i){c+=$i};print c}' > $outdir$'CigarMatEq'
paste $outdir'SamNames' $outdir$'CigarMatEq' > $outdir'ReadNameCigarMatEq'
echo "3.3 Merging alignment match count per read..."
paste  $outdir'ReadNameCigarMatX' $outdir'ReadNameCigarMatEq' | awk '{print $1, ($2+$4)}' > $outdir'ReadNameCigarMat'

# mapped read length
echo "Calculating mapped read length (M+I)..."
join <(sort -k 1b,1 $outdir'ReadNameCigarMat') <(sort -k 1b,1 $outdir'ReadNameCigarIns') | awk '{print $1, ($2+$3)}' > $outdir'MapReadLength'

# reference length to which read hap been mapped
echo "Calculating reference length at mapping fragment (M+D)..."
join <(sort -k 1b,1 $outdir'ReadNameCigarMat') <(sort -k 1b,1 $outdir'ReadNameCigarDel') | awk '{print $1, ($2+$3)}' > $outdir'RefReadLength'

# perc alignment mtch read
echo "Calculating percentage of alignment match in mapped read length (M/M+I)..."
join <(sort -k 1b,1 $outdir'ReadNameCigarMat') <(sort -k 1b,1 $outdir'MapReadLength') | awk '!$3 {exit ; }{print $1, ($2/$3)}' > $outdir'AlnMatchPercRead'

# perc alignment mtch reference
echo "Calculating percentage of alignment match in mapped reference length (M/M+D)..."
join <(sort -k 1b,1 $outdir'ReadNameCigarMat') <(sort -k 1b,1 $outdir'RefReadLength') | awk '!$3 {exit ; }  {print $1, ($2/$3)}' > $outdir'AlnMatchPercRef'

# perc alignment insertions read
echo "Calculating percentage of alignment match in mapped read length (I/M+I)..."
join <(sort -k 1b,1 $outdir'ReadNameCigarIns') <(sort -k 1b,1 $outdir'MapReadLength') | awk '!$3 {exit ; }{print $1, ($2/$3)}' > $outdir'AlnInsPercRead'

# perc alignment deletions reference
echo "Calculating percentage of alignment match in mapped reference length (D/M+D)..."
join <(sort -k 1b,1 $outdir'ReadNameCigarDel') <(sort -k 1b,1 $outdir'RefReadLength') | awk '!$3 {exit ; }{print $1, ($2/$3)}' > $outdir'AlnDelPercRef'

# merge basic stats
paste $outdir'MapReadLength' $outdir'RefReadLength' $outdir'AlnMatchPercRead' $outdir'AlnMatchPercRef' $outdir'AlnInsPercRead' $outdir'AlnDelPercRef' | awk '{print $1,$2,$4,$6,$8,$10,$12}' > $outdir'AlnCalc'

# merge all info tgth
join <(sort -k 1b,1 $outdir'ReadSpec') <(sort -k 1b,1 $outdir'AlnCalc') > $outdir'AlnStats'

# mapped length to mapped read
echo "Calculating proportion of mapped length to the total read length... "
cat $outdir'AlnStats' | awk '!$2 {exit ; }{print $5/$2}' > $outdir'ReadAlnLen'
# mapped length to ref length
echo "Calculating proportion of mapped length to the reference length... "
cat $outdir'AlnStats' | awk '!$6 {exit ; }{print $5/$6}' > $outdir'ReadRefLen'

# add info on mismatch
paste $outdir'AlnStats' $outdir'ReadAlnLen' $outdir'ReadRefLen' > $outdir'AlnStatsSpecTmp'

echo -e "ReadName\tReadLength\tAlignmentFlag\tAlignmentType\tMappedReadLength\tMappedReferenceLength\tAlignmentMatchReadRate\tAlignmentMatchReferenceRate\tAlignmentInsertionsRate\tAlignmentDeletionsRate\tMappedReadtoReadRate\tMappedReadToRefRate" | cat - $outdir'AlnStatsSpecTmp' > $outdir'AlnStatsSpec'

# how many alignments
echo "Calculating alignment number... "
cat $outdir'AlnStatsSpec' | sed -e "1d" | wc -l > $outdir'AlignNumber'
# how many input reads 
echo "Calculating read number... "
cat $outdir'AlnStatsSpec' | sed -e "1d" | awk '{print $1}' | uniq | wc -l > $outdir'ReadNumber'

# how many unique alignments 
echo "Calculating unique alignments... "
cat $outdir'ReadNumber' | awk '{print $2}' | grep -w 1 | wc -l > $outdir'UniquelyMappedReads'
# how many multiple mapped reads 
echo "Calculating multiple alignments... "
cat $outdir'ReadNumber' | awk '{print $2}' | grep -v -w 1 | wc -l > $outdir'MultipleMappedReads'

# average read length
echo "Calculating mean of read length... "
awk '{ sum += $2; n++ } END { if (n > 0) print sum / n; }' $outdir'AlnStatsSpec' > $outdir'MeanReadLength'
# sd of read length
echo "Calculating sd of read length... "
awk '{sum+=$2; sumsq+=$2*$2} END {print sqrt(sumsq/NR - (sum/NR)**2)}'  $outdir'AlnStatsSpec' > $outdir'SdReadLength'

# average mapped read length
echo "Calculating mean of mapped read length... "
awk '{ sum += $5; n++ } END { if (n > 0) print sum / n; }' $outdir'AlnStatsSpec' > $outdir'MeanMapReadLength'
# sd of read length
echo "Calculating sd of mapped read length... "
awk '{sum+=$5; sumsq+=$5*$5} END {print sqrt(sumsq/NR - (sum/NR)**2)}'  $outdir'AlnStatsSpec' > $outdir'SdMapReadLength'

# average mapped read length
echo "Calculating mean of mapped reference length... "
awk '{ sum += $6; n++ } END { if (n > 0) print sum / n; }' $outdir'AlnStatsSpec' > $outdir'MeanMapRefLength'
# sd of read length
echo "Calculating sd of mapped reference length... "
awk '{sum+=$6; sumsq+=$6*$6} END {print sqrt(sumsq/NR - (sum/NR)**2)}'  $outdir'AlnStatsSpec' > $outdir'SdMapRefLength'

# average mapped read length
echo "Calculating mean of portion of mapped read on its total length... "
awk '{ sum += $11; n++ } END { if (n > 0) print sum / n; }' $outdir'AlnStatsSpec' > $outdir'MeanReadtoReadRate'
# sd of read length
echo "Calculating sd of portion of mapped read on its total length... "
awk '{sum+=$11; sumsq+=$11*$11} END {print sqrt(sumsq/NR - (sum/NR)**2)}'  $outdir'AlnStatsSpec' > $outdir'SdReadtoReadRate'

# average mapped read length
echo "Calculating mean of portion of mapped read on mapped reference length... "
awk '{ sum += $12; n++ } END { if (n > 0) print sum / n; }' $outdir'AlnStatsSpec' > $outdir'MeanReadtoRefRate'
# sd of read length
echo "Calculating sd of portion of mapped read on mapped reference length... "
awk '{sum+=$12; sumsq+=$12*$12} END {print sqrt(sumsq/NR - (sum/NR)**2)}'  $outdir'AlnStatsSpec' > $outdir'SdReadtoRefRate'

# average match in read length
echo "Calculating average percentage of mapping in mapped read length... "
awk '{ sum += $7; n++ } END { if (n > 0) print sum / n; }' $outdir'AlnStatsSpec' > $outdir'MeanAlignmentMatchReadRate'

# average match in ref length
echo "Calculating average percentage of mapping in mapped reference length... "
awk '{ sum += $8; n++ } END { if (n > 0) print sum / n; }' $outdir'AlnStatsSpec' > $outdir'MeanAlignmentMatchRefRate'

# average alignement insertion rate
echo "Calculating average percentage of insertions in mapped read length... "
awk '{ sum += $9; n++ } END { if (n > 0) print sum / n; }' $outdir'AlnStatsSpec' > $outdir'MeanInsReadRate'

# average alignement insertion rate
echo "Calculating average percentage of deletions in mapped read length... "
awk '{ sum += $10; n++ } END { if (n > 0) print sum / n; }' $outdir'AlnStatsSpec' > $outdir'MeanDelReadRate'


# prepare final file 
echo "Finalizing..."
echo $samfile > $outdir'MapperName'

paste $outdir'MapperName' $outdir'AlignNumber' $outdir'MeanReadLength' $outdir'SdReadLength' $outdir'MeanMapReadLength' $outdir'SdMapReadLength' $outdir'MeanMapRefLength' $outdir'SdMapRefLength' $outdir'MeanReadtoReadRate' $outdir'SdReadtoReadRate' $outdir'MeanReadtoRefRate' $outdir'SdReadtoRefRate' $outdir'MeanAlignmentMatchReadRate' $outdir'MeanAlignmentMatchRefRate' $outdir'MeanInsReadRate' $outdir'MeanDelReadRate' > $outdir'FinalTableTmp'

echo -e "MapperName\tAlignmentNumber\tMeanReadLength\tSdReadLength\tMeanMappedReadLength\tSdMapReadLength\tMeanMappedRefLength\tSdMapRefLength\tMeanReadtoReadRate\tSdReadtoReadRate\tMeanReadtoRefRate\tSdReadtoRefRate\tMeanAlignmentMatchReadRate\tMeanAlignmentMatchRefRate\tMeanInsReadRate\tMeanDelReadRate" | cat - $outdir'FinalTableTmp' > $outdir'FinalTable'
echo "DOne. Output written to FinalTable. "

