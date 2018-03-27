#!/bin/bash
set -ev
git clone https://${GH_REF} .deploy_git
cd .deploy_git
git checkout master
cd ../
mv .deploy_git/.git/ ./public/
cd ./public
git config user.name  "wxiguo"
git config user.email "wxq9375@gmail.com"
# add commit timestamp
git add .
git commit -m "Travis CI Auto Builder at `date +"%Y-%m-%d %H:%M"`"
git push --force --quiet "https://${REPO_TOKEN}@${GH_REF}" master:master