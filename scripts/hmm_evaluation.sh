#!/bin/bash

#after downloading the data from Uniprot, unzip the files and save the data into FASTA files
zcat uniprotkb_reviewed_true_AND_xref_pfam_P_2026_05_12.fasta.gz > positive_kunitz.fasta
zcat uniprotkb_reviewed_true_NOT_xref_pfam_P_2026_05_12.fasta.gz > negative_kunitz.fasta

#check that the number of sequences matches your search results
grep ">" <your_file.fasta> | wc -l

#run the model against each file and save the output to a new file
hmmsearch -Z 1000 --tblout kunitz.hmm positive_kunitz.fasta > pos_results.table
hmmsearch -Z 1000 --tblout kunitz.hmm negative_kunitz.fasta > neg_results.table

#get the id, e-value and real class, to calculate the validation metrics
grep -v "^#" pos_results.table | awk '{print $1, $8, 1}' > pos_hits.txt
grep -v "^#" neg_results.table | awk '{print $1, $8, 0}' > neg_hits.txt

#to retrieve the negative non-match ids, you need to compare all the results from the model and the initial ids from the zip files  
#sort and clean the data
grep ">" positive_kunitz.fasta | awk '
{print $1}' | tr -d '>' | sort > master_list.ids
grep ">" negative_kunitz.fasta | awk '
{print $1}' | tr -d '>' | sort > master_list.ids
grep -v "^#" pos_results.table | awk '
{print $1}' | sort > match_list.ids
grep -v "^#" neg_results.table | awk '
{print $1}' | sort > match_list.ids
Sort master_list.ids
Sort match_list.ids

#compare the id lists
comm -23 master_list.ids match_list.ids > missing_ids.txt
awk '{print $1, 100, 0}' missing_ids.txt > negatives.nomatch


