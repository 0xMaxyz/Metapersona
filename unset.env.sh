#!/bin/bash
if [ ! -r .env ]; then
    echo "Error: .env file is missing or not readable."
    exit 1
fi

while IFS= read -r line; do
  if [[ $line =~ ^# ]]; then
    continue
  fi

  varname=$(echo "$line" | cut -d '=' -f1)

  unset "$varname"
done < <(cat .env; echo)

echo "Environment variables in .env have been unset."
