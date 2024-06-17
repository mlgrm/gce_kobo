#!/bin/bash -xe
docker run hello-world
sudo apt-get install git
git clone https://github.com/kobotoolbox/kobo-install.git
cd kobo-install
git checkout master
# python3 run.py
