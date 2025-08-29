#!/usr/bin/env bash
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

# Compile, with JSoup jar
echo "Compiling..."
javac -cp jsoup-1.21.2.jar Tokenizer.java

# Loop through .html files
find "$IN_DIR" -type f -name '*.html' -print0 | while IFS= read -r -d '' FILE; do
  
  BASENAME="$(basename "$FILE" .html)"
  OUTFILE="$OUT_DIR/$BASENAME.txt"

  # Run, with JSoup jar
  java -cp .:jsoup-1.21.2.jar Tokenizer "$FILE" "$OUTFILE"

  echo ""
done

echo "Script done!"