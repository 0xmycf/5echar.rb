#! /usr/bin/env bash

bundle exec bin/dndchar \
  --name "Fighter McFight Fight" \
  --level 3 \
  --class Fighter \
  --subclass "Champion" \
  --background "Acolyte" \
  --spells "Druidcraft" \
  --attributes "10, 10, 10, 10, 10, 10" \
  --feats "Brawler, Magic Initiate, Archery" \
  --to-pdf MyRanger.pdf
