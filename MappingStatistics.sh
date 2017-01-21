#!/bin/bash
echo "Suggested alignment files: "
ls *.sam
# enter your file
echo "Input the alignment file of your choice (.sam), followed by [ENTER]:"
read samfile
echo "Input path to alignment file, followed by [ENTER]:"
read sampath
# enter outdir
echo "Input the output directory you want to write to, followed by [ENTER]:"
read outdir
mkdir -p $outdir

# uniquely mapped reads
echo "Getting the list of uniquely mapped reads..."
cat $sampath$samfile | grep -v ^@ | sed 's/ [^\t]*\t/\t/' | awk '{if($2!=4 && $2!=256 && $2!=272 && $2!=2048 && $2!=2064){print$0}}' | awk '{print $1}' | awk '!seen[$1]++' | sort > $outdir$samfile'_uniquely_mapped'

# unmapped reads
echo "Getting the list of unmapped reads..."
cat $sampath$samfile | grep -v ^@ | sed 's/ [^\t]*\t/\t/' | awk '{if($2==4){print$0}}' | awk '{print $1}' | awk '!seen[$1]++' | sort > $outdir$samfile'_unmapped'

# ambiguously mapped reads
echo "Getting the list of ambiguously mapped reads..."
comm -12 $outdir$samfile'_unmapped' $outdir$samfile'_uniquely_mapped' > $outdir$samfile'_ambiguous'

# unambiguously unmapped reads
echo "Getting the list of unambiguously unmapped reads..."
comm -23 $outdir$samfile'_unmapped' $outdir$samfile'_uniquely_mapped' > $outdir$samfile'_unambiguously_unmapped'

# unambiguously mapped reads
echo "Getting the list of unambiguously unmapped reads..."
comm -13 $outdir$samfile'_unmapped' $outdir$samfile'_uniquely_mapped' > $outdir$samfile'_unambiguously_mapped'

echo "Finalizing..."
Ambiguous=$(cat $outdir$samfile'_ambiguous' | wc -l)
UnambiguousUnmapped=$(cat $outdir$samfile'_unambiguously_unmapped' | wc -l)
UnambiguousMapped=$(cat $outdir$samfile'_unambiguously_mapped' | wc -l)

echo "Results: "
echo "Unambiguously mapped: $UnambiguousMapped"
echo "Unambiguously unmapped: $UnambiguousUnmapped"
echo "Ambiguous: $Ambiguous"

echo "Done."
