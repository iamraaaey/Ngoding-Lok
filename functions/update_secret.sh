#!/bin/bash
echo "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" | firebase functions:secrets:set OPENROUTER_API_KEY
echo "AIzaSyAMXVCFmqiditgTUi-x" | firebase functions:secrets:set GEMINI_API_KEY
echo "Secrets updated."
