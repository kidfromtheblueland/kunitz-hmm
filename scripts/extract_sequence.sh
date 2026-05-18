#!/bin/bash
#after you save the custom report as a .csv file
#remove empty lines that start with a comma

awk -F "," '{if ($1 != "") print $1,$3,$2}' rcsb_pdb_custom_report_20260415204951.csv | less

#ensure each chain actually contains the Kunitz domain (discarding co-crystallized partner proteins)

grep -v "^," rcsb_pdb_custom_report_20260415204951.csv | tr -d '"' | tr "," " " | less

#discard sequences that are too short (e.g., < 40 residues) as they may be incomplete fragments that would not align well

awk -F "," '{if ($1 != "" && length($2)<80 && length($2)>40) print $1,$3,$2}' rcsb_pdb_custom_report_20260415204951.csv | tr -d '"' | less

#save the id(s) and chains to a .txt file

awk -F "," '{if ($1 != "" && length($2)<80 && length($2)>40) print $1,$3,$2}' rcsb_pdb_custom_report_20260415204951.csv | tr -d '"' | awk '{print ">"$1$2;print $3}' > pdb_seqs.txt
