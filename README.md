# A Hidden Markov Model-Based Approach for the Automatic Classification and Annotation of Kunitz BPTI Domains

<img width="2816" height="1412" alt="Gemini_Generated_Image_tf4hu9tf4hu9tf4h (1)" src="https://github.com/user-attachments/assets/dc3509ec-6792-43be-8cd8-10db13c5827b" />

This repository provides the complete pipeline and materials used to build, evaluate, and validate a profile HMM for detecting Kunitz-type domains in protein sequences. The project was developed as the final assessment for the Laboratory of Bioinformatics 1 course at the University of Bologna.

# Project Overview

Profile Hidden Markov Model for the classification of Kunitz-type protease inhibitor domains. Includes structural data curation from PDB, MMseqs2 clustering, PDBeFold alignment, HMM construction with HMMER, and rigorous benchmarking on Swiss-Prot datasets. Final project for the Laboratory of Bioinformatics course at the University of Bologna.

# Repository Structure

kunitz-hmm/
├── README.md
├── LICENSE
├── requirements.txt
├── environment.yml
├── .gitignore
│
├── data/
│   ├── benchmark/
│   │   ├── positive_kunitz.fasta
│   │   └── negative_kunitz.fasta
│   └── results/
│       ├── pos_results.table
│       ├── neg_results.table
│       ├── all_preds.txt
│       ├── set1.txt
│       └── set2.txt
│
├── structures/
│   ├── raw/                    # Original downloaded PDBs
│   └── final_chains/           # Cleaned chains (e.g. 3ZCF_A.pdb)
│
├── alignments/
│   ├── msa.seq
│   └── kunitz.ali
│
├── models/
│   └── kunitz.hmm
│
├── scripts/
│   ├── getchain.py
│   ├── performance.py
│   ├── download_pdbs.sh
│   ├── extract_chains.sh
│   ├── build_hmm.sh
│   ├── run_hmmsearch.sh
│   └── cross_validation_prep.sh     
│
├── notebooks/
│   └── Kunitz_HMM_Visualization.ipynb
│       
└── figures/
    ├── mcc_vs_threshold.png
    ├── rmsd_heatmaps_comparison.png
    ├── sequence_identity_heatmap.png
    └── sequence_logo.png

# Project Workflow
## 1. Data Acquisition and Preprocessing

    ● Data was retrieved from RCSB PDB using a custom query:

      ○ Pfam ID: PF00014
      ○ Resolution ≤ 3.5 Å
      ○ Sequence length 40–80 residues

    ● A custom report was downloaded from the RCSB website, including the following fields:

      ○ Entry ID
      ○ Polymer Entity ID
      ○ Sequence
      ○ Annotation Identifier
      ○ Chain ID
    
    ● The protein sequences were extracted from the CSV report using scripts/extract_sequence.sh

## 2. Sequence Clustering

    ● Used MMseqs2 platform (https://toolkit.tuebingen.mpg.de/tools/mmseqs2) to cluster the protein chains
    ● Identity threshold: 95%, coverage: 95%
    ● Output: clustered sequences for further analysis

## 3. ID Extraction for Structural Search

    ● Used scripts/extract_pid.sh to format IDs for PDBeFold

## 4. Structural Filtering

    ● Used scripts/getchain.py to extract/isolate from each PDB file the structure of the desired chain containing the Kunitz domain

'''bash
while IFS=':' read -r pdb chain; do
    python getchain.py "$pdb.pdb" "$chain" > "${pdb}_${chain}.pdb" done < pdb_id.rep

#to clean the list of any hidden characters
tr -d '\r' < pdp_id.rep > clean_pdp_id.rep'''

