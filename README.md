# Backpack Currencies Enhanced

World of Warcraft addon that helps managing currencies directly from the currency bar under the bag.

## Downloading the addon

The addon is [available at CurseForge](https://www.curseforge.com/wow/addons/backpack-currencies-enhanced), which is currently undergoing a migration from Twitch to Overwolf.

## Packaging

The addon is packaged into a zip file through the `build.sh` script. Make sure your environment has the `zip` command installed.

## Changes 

### 1.3

- Fixed multiple bugs relative to the 9.0.1 API changes.

- Used the Blizzard API colors for the currency amounts.

- Used the Blizzard API formatting logic for the currency amounts now that it supports huge numbers.

### 1.2

- Fixed a bug from a call to a function that was moved to another namespace.
