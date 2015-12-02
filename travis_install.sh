#!/bin/bash

# create virtualenv
deactivate
virtualenv --system-site-packages testenv
source testenv/bin/activate

# Python dependencies
sudo pip install --upgrade pip
sudo pip install numpy
sudo pip install SciPy
sudo pip install pandas
sudo pip install csv
# tensorflow for separate os
if [ ${TRAVIS_OS_NAME} == "linux" ]; then
  sudo pip install https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.5.0-cp27-none-linux_x86_64.whl
fi
if [ ${TRAVIS_OS_NAME} == "osx" ]; then
  sudo pip install https://storage.googleapis.com/tensorflow/mac/tensorflow-0.5.0-py2-none-any.whl
fi
sudo pip install git+git://github.com/google/skflow.git

# R dependencies
curl -OL http://raw.github.com/craigcitro/r-travis/master/scripts/travis-tool.sh
chmod 755 ./travis-tool.sh
./travis-tool.sh bootstrap
./travis-tool.sh install_aptget r-cran-testthat r-cran-devtools r-cran-rPython
./travis-tool.sh install_deps
