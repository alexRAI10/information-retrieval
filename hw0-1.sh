#!/usr/bin/env bash

echo "Compiling..."
javac tiny_tokenize.java
echo

if [[ $# -ne 2 ]]; then
  echo "Args should be: $0 Input_file Output_file" >&2
  echo "Please Try Again"
  exit 1
fi


java tiny_tokenize $1 $2
echo

echo "Script done!"