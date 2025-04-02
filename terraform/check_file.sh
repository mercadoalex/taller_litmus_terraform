#!/bin/bash

FILE=$1

if [ -f "$FILE" ]; then
  # If the file exists, return its content as a JSON object
  CONTENT=$(cat "$FILE" | jq -Rs .) # Escape the file content as a JSON string
  echo "{\"content\": $CONTENT}"
else
  # If the file does not exist, return an empty JSON object
  echo "{\"content\": \"\"}"
fi