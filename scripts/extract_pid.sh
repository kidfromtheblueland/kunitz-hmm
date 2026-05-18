#!/bin/bash

#choose the first sequence in each cluster in the "mmseqs2.out" file as the representative and save them into a new filemanually

vim pdb_seqs.clust

#clean the file so that only protein id and the target chain remain

grep -A 1 ^Clus pdb_seqs.clust | grep ">" | tr -d ">" | less
grep -A 1 ^Clus pdb_seqs.clust | grep ">" | tr -d ">" > pdb_id.rep

#specify the PDB entries as "PDB:CHAIN" and change manually the content, adding ":"

vim pdb_id.rep

#to download PDB structures only protein ids are needed

cut -d ':' -f 1 pdb_id.rep > list_pdb.txt

#download the PDB structures for each id

for i in $(cat list_pdb.txt); do wget https://files.rcsb.org/download/$i.pdb; done
