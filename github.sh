#!/bin/bash

git init
git add .
git commit -a -m "First commit"
git remote add $1
git push -u origin master
