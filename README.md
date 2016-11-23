# misc_genomics
useful scripts for genomics

Description:
- `FastaStats.sh`: get statistics on input .fasta file (read length, read name, read number)
- `MapTableFullCigar.sh` : get statistics on aligners output given alignment file in .sam format and sequencing read file in .fasta format - used for benchmark of aligners when the aligner is set to output a .sam with full cigar string (aka, reporting details on matches and mismatches information (X,=))
- `MapTable.sh` : get statistics on aligners output given alignment file in .sam format and sequencing reads in .fasta format - used for banchmark of aligners when the aligner is set to output a general cigar string, with broad information about alignment match (M)
- `CoverageCalculator.sh`: get raw coverage information for uneven read length sequencing data (based on median)
