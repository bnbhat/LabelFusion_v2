#!/bin/bash
#
# This script is run by the dockerfile during the docker build.
#

set -ex

apt-get update


# basic packages
apt-get install -y --no-install-recommends \
  sudo git bash-completion

# dependency for Director
apt-get install -y --no-install-recommends \
  build-essential cmake libglib2.0-dev \
  libx11-dev libxext-dev libxt-dev \
  libqt4-dev \
  python-dev python-lxml python-numpy python-scipy python-yaml

# dependency for QT5
apt-get install -y --no-install-recommends \
 qt5-default

# dependency for VTK7
apt-get install -y --no-install-recommends \
  vtk7


# original one deleted
# apt-get install -y \
#   libboost-all-dev \
#   libglew-dev \
#   libjpeg-dev \
#   libeigen3-dev \
#   libopencv-dev \
#   libopenni2-dev \
#   libqhull-dev \
#   libqwt-dev \
#   libsuitesparse-dev \
#   libudev-dev \
#   libusb-1.0-0-dev \
#   mesa-utils \
#   openjdk-8-jdk \
#   zlib1g-dev \
#   libyaml-cpp-dev \
#   python-matplotlib \
#   python-pip \
#   python-vtk \


# Figure out the dependencies
# original one
# apt-get install -y \
#   bash-completion \
#   build-essential \
#   cmake \
#   freeglut3-dev \
#   git \
#   libboost-all-dev \
#   libglew-dev \
#   libjpeg-dev \
#   libeigen3-dev \
#   libopencv-dev \
#   libopenni2-dev \
#   libqhull-dev \
#   libqt4-dev \
#   libqwt-dev \
#   libsuitesparse-dev \
#   libudev-dev \
#   libusb-1.0-0-dev \
#   libvtk5-dev \
#   libvtk5-qt4-dev \
#   mesa-utils \
#   openjdk-8-jdk \
#   zlib1g-dev \
#   libyaml-cpp-dev \
#   python-dev \
#   python-matplotlib \
#   python-numpy \
#   python-pip \
#   python-scipy \
#   python-vtk \
#   python-yaml \
#   sudo


  # optional cleanup to make the docker image smaller
  # rm -rf /var/lib/apt/lists/*
