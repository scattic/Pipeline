#!/bin/bash

echo !!! RUN THIS SCRIPT FROM WITHIN THE VM, KTHXBYE !!!
echo This script will push changes from GOGS to GitHub
echo WARNING: changes on GitHub will not be considered, and will break the sync

cd /mnt/challenge/
git pull origin master
git add . 
git commit -m "update"
git push --set-upstream origin master
git remote remove origin
git remote add origin https://github.com/scattic/pipeline.git
git push --set-upstream origin master
git remote remove origin
git remote add origin http://localhost:3000/zeus/pipeline.git
git push --set-upstream origin master
