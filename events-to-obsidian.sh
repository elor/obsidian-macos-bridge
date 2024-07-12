#!/bin/bash

set -e -u

# Get today's date in ISO format
TODAY=$(date +"%Y-%m-%d")
VAULT=~/Documents/Speicherwolke/Notes/

# Get the calendar events for today using icalBuddy
{
  obsidian-macos-calendar-bridge
  echo
} | sed -i -e '/^$/r /dev/stdin' $VAULT/Daily/"$TODAY Daily Note.md"

echo "wrote events to $VAULT/Daily/$TODAY Daily Note.md"
