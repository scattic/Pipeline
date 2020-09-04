#!/bin/bash

echo !!! RUN THIS SCRIPT FROM WITHIN THE VM, KTHXBYE !!!
cd /mnt/challenge/
git remote remove origin
git remote add origin https://github.com/scattic/pipeline.git
git push --set-upstream origin master
git remote remove origin
git remote add origin http://localhost:3000/zeus/pipeline.git
git push --set-upstream origin master
