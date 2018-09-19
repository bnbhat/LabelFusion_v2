#!/bin/bash
#
# This script is run by the dockerfile during the docker build.
#

set -exu

root_dir=$(pwd)
install_dir=$root_dir/install


build_elasticfusion()
{
  cd $root_dir
  git clone https://github.com/ianre657/ElasticFusion.git
  cd ElasticFusion
  #git checkout rs2_labelfusion
  git checkout pf-lm-debug-jpeg

  git clone https://github.com/stevenlovegrove/Pangolin.git
   cd Pangolin
   mkdir build
   cd build
   cmake ../ -DAVFORMAT_INCLUDE_DIR="" -DCPP11_NO_BOOST=ON
   make -j$(nproc) -l$(nproc)
   cd ../..

  export CMAKE_PREFIX_PATH=$install_dir
  cd Core
  mkdir build
  cd build
  cmake ../src
  make -j$(nproc) -l$(nproc)

  cd ../../GPUTest
  mkdir build
  cd build
  cmake ../src
  make -j$(nproc) -l$(nproc)

  cd ../../GUI
  mkdir build
  cd build
  cmake ../src -DCMAKE_PREFIX_PATH="/opt/ros/melodic"
  make -j$(nproc) -l$(nproc)

  ln -s $(pwd)/ElasticFusion $install_dir/bin

  # cleanup to make the docker image smaller
  cd ../..
  find . -name \*.o | xargs rm
}

build_elasticfusion
