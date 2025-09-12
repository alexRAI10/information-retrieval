#!/usr/bin/env bash

# Authors: Alain Delgado, Micah McCollum
set -euo pipefail

# Verify if there are two arguments Input_directory and Output_directory
if [[ $# -ne 2 ]]; then
  echo "Args should be: $0 Input_directory Output_directory" >&2
  echo "Please Try Again"
  exit 1
fi

IN_DIR="$1"
OUT_DIR="$2"

# Error check in case no input directory was found
if [[ ! -d "$IN_DIR" ]]; then
  echo "Error: Input_directory not found: $IN_DIR" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

echo "Compiling Lexer.java..."
jflex lexer.jflex

echo "Compiling Tokenizer.java..."
javac Tokenizer.java Lexer.java

##### Generate the 3 required files: tokenized output directory, alpha.txt, and freqs.txt #####

MAX_FILES=1500
IN_FILES=( "$IN_DIR"/*.html )

# Loop through .html files up to MAX_FILES or until none are remaining
for ((i=0; i<MAX_FILES && i<${#IN_FILES[@]}; i++)); do
  FILE="${IN_FILES[i]}"
  BASENAME="$(basename "$FILE" .html)"
  OUTFILE="$OUT_DIR/$BASENAME.txt"

  java Tokenizer "$FILE" "$OUTFILE"

  echo ""
done

### Before generating the remaining three files, delete them if they exist so they won't be included in the generation!
rm -f "$OUT_DIR"/all_tokens.txt "$OUT_DIR"/alpha.txt "$OUT_DIR"/freqs.txt  

# Collect all tokens from output directory and store in text file
cat "$OUT_DIR"/* > "$OUT_DIR"/all_tokens.txt

# Sort alphabetically and generate alpha.txt
sort "$OUT_DIR"/all_tokens.txt | uniq -c > "$OUT_DIR"/alpha.txt

# Sort by frequency first and generate freqs.txt
sort -k1,1nr -k2,2 "$OUT_DIR"/alpha.txt > "$OUT_DIR"/freqs.txt

echo "Script done!"