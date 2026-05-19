# A Hidden Markov Model-Based Approach for the Automatic Classification and Annotation of Kunitz BPTI Domains

![](https://img.shields.io/badge/university-Bologna-red)
![](https://img.shields.io/badge/course-Bioinformatics-Lab-1-brightblue)
![](https://img.shields.io/badge/python-3.13+-blue)
![](https://img.shields.io/badge/tool-HHMER-purple)
![](https://img.shields.io/badge/tool-PDBeFold-purple)
![](https://img.shields.io/badge/tool-MMseqs2-yellow)


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
    │   ├── positive_kunitz.fasta
    │   ├── negative_kunitz.fasta
    │   ├── total_neg.txt
    │   ├── pos_results.table
    │   ├── neg_results.table
    │   ├── all_preds.txt
    │   ├── set1.txt
    │   └── set2.txt
    │
    ├── structures/
    │   ├── raw/                    
    │   └── final_chains/          
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
    │   ├── extract_sequence.sh
    │   ├── extract_pid.sh
    │   └── hmm_evaluation.sh     
    │
    ├── notebooks/
    │   └── Kunitz_HMM_Visualization.ipynb
    │       
    └── figures/
        ├── mcc_vs_threshold.png
        ├── rmsd_heatmap_A.png
        ├── rmsd_heatmap_B.png
        ├── chimera_superimposition.png
        ├── sequence_identity_heatmap.png
        └── sequence_logo.png

# Project Workflow
## 1. Data Acquisition and Preprocessing

- Data was retrieved from RCSB PDB using a custom query:
    - Pfam ID: PF00014
    - Resolution ≤ 3.5 Å
    - Sequence length 40–80 residues

- A custom report was downloaded from the RCSB website, including the following fields:
    - Entry ID
    - Polymer Entity ID
    - Sequence
    - Annotation Identifier
    - Chain ID
    
- The protein sequences were extracted from the CSV report using `scripts/extract_sequence.sh`

## 2. Sequence Clustering

- Used MMseqs2 platform (https://toolkit.tuebingen.mpg.de/tools/mmseqs2) to cluster the protein chains

    - Identity threshold: 95%, coverage: 95%
    - Output: clustered sequences for further analysis

## 3. ID Extraction for Structural Search

- Used `scripts/extract_pid.sh` to format IDs for PDBeFold

## 4. Structural Filtering

- Used `scripts/getchain.py` to isolate and extract from each PDB file the structure of the desired chain containing the Kunitz domain

        while IFS=':' read -r pdb chain; do
        python getchain.py "$pdb.pdb" "$chain" > "${pdb}_${chain}.pdb" done < pdb_id.rep
                    
        #to clean the list of any hidden characters
        tr -d '\r' < pdp_id.rep > clean_pdp_id.rep

  
## 5. Structural Alignment

- Performed all-vs-all alignment on the PDBeFold platform
- Saved RMSD data as a matrix into a .csv file to create heatmaps
- Saved the alignment data as a FASTA file
- Visualized the alignment using AliView
- 6 outliers identified and excluded
- Performed the alignment once again with the refined data
- Saved the new RMSD and FASTA after the refinement
- Used UCSF Chimera to visualise the structures' superimposition

## 6. HMM Construction

        hmmbuild kunitz.hmm kunitz.ali

## 6. HMM Evaluation

This section details the analytical frameworks used to test the diagnostic power of our generated profile HMM, ensuring robust classification performance on unknown datasets.

### Evaluation Methodology:

- Data Splitting: Utilizing a 2-fold split strategy to extract maximum value from the dataset.
- Leakage Control: Isolating and removing training sequences from the evaluation pool to ensure an unbiased test.
- Statistical Metrics: Scoring the model based on MCC, Sensitivity (Sn/Recall), and Precision.
- Threshold Optimization: Testing an array of E-value cutoffs to identify peak classifier performance.

### Validation Datasets

- `positive_kunitz.fasta`
- `negative_kunitz.fasta`
- `negatives.nomatch`

### Analysis Pipeline

 1. Dataset Curation: Aggregate data pools and strip out any overlapping training sequences to prevent leakage.
 2. Fold Generation: Randomly divide the filtered data into balanced positive and negative subsets.
 3. Model Execution: Query the validation folds against the trained HMM using local hmmsearch calls.
 4. Performance Assessment: Parse the output logs to calculate core predictive metrics.
 5. Analysis Export: Generate final performance summaries and evaluate optimal score thresholds.

# Environment Setup

To ensure reproducibility and manage software versions, a dedicated Conda environment can be used. This creates an isolated space where specific bioinformatics tools and Python libraries are installed without conflicting with the system-wide settings.


    #create the environment
    conda create -n kunitz_project python=3.x
    #activate the environment
    conda activate kunitz_project
    #install bioinformatics tools
    conda install -c bioconda hmmer mmseqs2 blast
## Key  Dependencies and Utilities

- Python 3.13 with standard libraries (NumPy, Pandas, Matplotlib, Biopython, Seaborn)
- Bioinformatics tools: HMMER suite, MMseqs2, NCBI BLAST, PBDeFold, Aliview
- Standard Unix Utilities: wget, grep, awk, comm, sort

# Performance Assessment

## False Negative Results

| UniProt ID | Length | Domains | Domain Position | Comments
| --- | --- | --- | --- | --- |
| A0A1Q1NL17 | 101 | 1 | 32-88 | Short sequence; Kunitz-type anticoagulant protein HA11 |
| Q8WPG5 | 134 | 2 | 17-69, 83-129 | Tandem domains; Thrombin inhibitor savignin |

The optimal threshold was identified at 1e-5, yielding the following performance:
Accuracy: 1.0000
Precision: 1.0000
Recall (Sensitivity): 0.9943
Specificity: 1.0000
F1-score: 0.9971
MCC: 0.9971

# Future Improvements
- Expand the training set by incorporating the two false negative sequences (tick-derived Kunitz inhibitors) to improve sensitivity toward divergent invertebrate variants.
- Explore ensemble approaches by combining multiple HMMs or integrating structural information from AlphaFold-predicted models.
- Test the model on larger, uncurated databases (e.g., UniProt TrEMBL) to evaluate scalability and real-world performance.
- Develop a web tool or Python package for easy use of the model by the community.
- Investigate the use of deep learning-based methods (e.g., Transformer-based protein language models) for comparison with the classical HMM approach.

# Supervisor
Professor Emidio Capriotti

# License
This project is licensed under the MIT License (LICENSE).
