#!/bin/bash
set -ev

# get clone master
git clone https://${GH_REF} .deploy_git
cd .deploy_git
git checkout master

cd ../
mv .deploy_git/.git/ ./public/

cd ./public

git config user.name "wxiguo"
git config user.email "wxq9375@gmail.com"

# add commit timestamp
git add .
git commit -m "Travis CI Auto Builder at `date +"%Y-%m-%d %H:%M"`"

# Github Pages
git push --force --quiet "https://${TravisCIToken}@${GH_REF}" master:master
# Coding Pages
git push --force --quiet "https://wxiguo:eead5a9cc0e7279fb7a86b0a47eeee61b1c80afc@${CO_REF}" master:master