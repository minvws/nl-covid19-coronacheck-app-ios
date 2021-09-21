#!/bin/bash

# Config
BASE_REPONAME=nl-covid19-coronacheck-app-ios

# Helpers
TIMESTAMP=`date '+%Y%m%d-%H%M%S'`
PR_TITLE="Sync+public+repo+from+private+repository" # Use + for spaces as this is used in a URL
PR_BODY="This+PR+proposes+the+latest+changes+from+private+to+public+repository.+Timestamp:+${TIMESTAMP}"
RED="\033[1;31m"
GREEN="\033[1;32m"
ENDCOL="\033[0m"
echo -e "${GREEN}Ensuring a safe environment${ENDCOL}"
if [ -z "$(git status --porcelain)" ]; then 
  # Working directory clean
  echo "Working directory clean"
else 
  # Uncommitted changes
  echo
  echo -e "${RED}Your working directory contains changes.${ENDCOL}"
  echo "To avoid losing changes, this script only works if you have a clean directory."
  echo "Commit any work to the current branch, and try again."
  echo 
  exit
fi

# To ensure the script works regardless of whether you run this from private or public, we ignore origin, and
# add 2 remotes, one for public, one for private
if ! git config remote.public-repo.url > /dev/null; then
    git remote add public-repo git@github.com:minvws/$BASE_REPONAME
    echo -e "${GREEN}Public-repo remote added${ENDCOL}"
fi

if ! git config remote.private-repo.url > /dev/null; then
    git remote add private-repo git@github.com:minvws/$BASE_REPONAME-private
    echo -e "${GREEN}Private-repo remote added${ENDCOL}"
fi

# Create a branch where we sync everything from current private main
echo -e "${GREEN}Ensuring we are in sync with the private repo${ENDCOL}"
git fetch private-repo 
git lfs fetch private-repo --all

echo -e "${GREEN}Creating a new sync branch based on private/main${ENDCOL}"
git branch sync/$TIMESTAMP private-repo/main

# Todo: this could be optimized to only push if there actually are changes between the two branches (if not, this currently creates an empty PR)
echo -e "${GREEN}Pushing the sync branch to public repo${ENDCOL}"
git push public-repo sync/$TIMESTAMP
git lfs push public-repo --all


# Push all (non-pushed) Release tags to public-repo
#
# This produces & executes commands like:
# 	git push public-repo refs/tags/Holder-8.8.8
# 	git push public-repo refs/tags/Holder-9.9.9

git show-ref --tags \ 		# get all hash/tag in pairs like "62578f6 refs/tags/2.1.3-Holder"
	| grep -v -F "$(git ls-remote --tags public-repo | grep -v '\^{}' | cut -f 2)" \ 		# Match only those that don't appear on `public-repo`
	| grep -e "Holder-" -e "Verifier-" \ 		# Match only those that are in our release tag format
	| grep -v "\-RC" \ 		# Strip out the RCs
	| cut -f2 -d " " \ 		# Get the tag name, drop the hash.
	| xargs -L1 git push public-repo # Finally push each tag to `public-repo` remote.

echo -e "${GREEN}Constructing a PR request and opening it in the browser${ENDCOL}"
PR_URL="https://github.com/minvws/$BASE_REPONAME/compare/sync/$TIMESTAMP?quick_pull=1&title=${PR_TITLE}&body=${PR_BODY}"

open $PR_URL

echo -e "${GREEN}Done.${ENDCOL}"
