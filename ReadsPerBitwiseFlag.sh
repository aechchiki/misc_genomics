#!/bin/bash
echo "Input alignment file (.sam), followed by [ENTER]:"
read samfile
echo "Number of reads per unique bitwise flag:"
less $samfile | grep -v ^@ | awk '{ print $2 }' | sort | uniq -c
echo "Done."
