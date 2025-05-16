#! /usr/bin/env bash

bundle exec bin/5echar \
  --name "Fighter McFight Fight" \
  --level 3 \
  --class "Fighter" \
  --subclass "Battle Master" \
  --background "Guard" \
  --spells "" \
  --attributes "16, 14, 14, 11, 12, 8" \
  --feats "Great Weapon Fighting, Savage Attacker" \
  --to-pdf "/tmp/Sjard-cheat-sheet.pdf"
