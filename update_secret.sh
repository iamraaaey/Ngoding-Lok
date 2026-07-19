#!/bin/bash
read -sp "Enter new Anthropic API Key: " NEW_KEY
echo ""
echo "$NEW_KEY" | firebase functions:secrets:set ANTHROPIC_API_KEY
echo "Secret updated."
