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

#compares two sorted files and outputs only the lines unique to the first file (the sequences present in the dataset but absent from the search results)
comm -23 master_list.ids match_list.ids > missing_ids.txt

#assign an arbitrarily high E-value (the dummy value). this ensures that these sequences will always be classified as negatives
#assign the real class label of 0, identifying them as known negatives
awk '{print $1, 100, 0}' missing_ids.txt > negatives.nomatch

#merge the match ids (negative sequences that received an e-value hit) and the no-match ids (rescued sequences that the model correctly ignored) into a single file for the confusion matrix
cat negative_kunitz.match negatives.nomatch > negative_tot_match.txt

