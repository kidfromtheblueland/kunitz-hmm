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
cat negative_kunitz.match negatives.nomatch > total_neg.txt

#the perormance.py script reads your prediction file (ID, E-value, Real Class), applies a threshold, and calculates the Confusion Matrix, Accuracy, and Matthews Correlation Coefficient (MCC)
for i in {1..20}; do     python3 performance.py all_preds.txt "1e-$i"; done

#perform a two-fold cross-validation to avoid overfitting
sort -R pos_hits.txt > pos_shuffled.txt
sort -R total_neg.txt > neg_shuffled.txt

#split each positive and negative set into two halves
head -n 174 pos_shuffled.txt > pos_half1.txt
tail -n 174 pos_shuffled.txt > pos_half2.txt

head -n 282497 neg_shuffled.txt > neg_half1.txt
tail -n 282496 neg_shuffled.txt > neg_half2.txt

#check if the have seperated correctly into two
wc pos_half1.txt pos_half2.txt
wc neg_half1.txt neg_half2.txt

#mix each positive half with a negative one to ensure diversity
cat pos_half1.txt neg_half1.txt > set1.txt
cat pos_half2.txt neg_half2.txt > set2.txt

#use one set to perform a grid-like search to identify the optimal e-value threshold that maximizes the MCC
for i in {1..20}; do     python3 performance.py set1.txt "1e-$i"; done

# after finding the best threshold on Set 1, apply it to Set 2, a subset of data the model's parameters had not "seen" during the initial optimization
python3 performance.py set2.txt 0.0001

#repeat the process in reverse (optimizing on Set 2 and testing on Set 1)
for i in {1..20}; do     python3 performance.py set2.txt "1e-$i"; done
python3 performance.py set1.txt 0.0001


