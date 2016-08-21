#!/bin/bash
echo "Input alignment file (.sam), followed by [ENTER]:"
read samfile
echo "Flags in input alignment file are the following:"
less $samfile | grep -v ^@ | awk '{ print $2 }' | sort | uniq
echo "Done."
