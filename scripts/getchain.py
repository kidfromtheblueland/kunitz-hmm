import sys

# Assign command-line arguments to variables
# sys.argv is the script name ('getChain.py')
# sys.argv[1] is the PDB file (e.g., '3ZCF.pdb')
# sys.argv[2] is the target Chain ID (e.g., 'A')
pdb_file = sys.argv[1]
target_chain = sys.argv[2]

# Open the PDB file for reading
with open(pdb_file, 'r') as fh:
    for line in fh:
        # Check if the record starts with 'ATOM'
        if line.startswith("ATOM"):
            # In the PDB format, the Chain ID is in column 22.
            # Python uses 0-based indexing, so column 22 is index 21.
            if line[21] == target_chain:
                # Print the line and strip the trailing newline character
                print(line.rstrip())



                

