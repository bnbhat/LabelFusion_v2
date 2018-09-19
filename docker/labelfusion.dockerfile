#FROM nvidia/cuda:8.0-devel-ubuntu16.04

# ubuntu 18.04 only support cuda9.2 with tesla,
#FROM nvidia/cudagl:9.2-devel-ubuntu18.04
FROM ianre657/ros-melodic-desktop-full-nvidia:latest

WORKDIR /root


COPY build_scripts /tmp/build_scripts

RUN apt-get update && apt-get upgrade -y
# install_dependencies
    # basic packages
RUN apt-get update && apt-get install -y --no-install-recommends \
  sudo git bash-completion lsb-core wget

    # for debuuging
RUN apt-get update && apt-get install -y --no-install-recommends \
  cmake-curses-gui vim apt-file \
  && apt-file update 

    # dependency for Director
RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential cmake libglib2.0-dev \
  libx11-dev libxext-dev libxt-dev \
  libqt4-dev \
  python-dev python-lxml python-numpy python-scipy python-yaml python3-vtk7 \
  qtmultimedia5-dev libqwt-qt5-dev openjdk-8-jdk qtbase5-private-dev \
  libeigen3-dev liblua5.2-dev libyaml-cpp-dev

    # dependency for ElasticFusion
RUN apt-get update && apt-get install -y --no-install-recommends \
  git libsuitesparse-dev cmake-qt-gui build-essential libusb-1.0-0-dev libudev-dev \
  freeglut3-dev libglew-dev libeigen3-dev zlib1g-dev libjpeg-dev \
  gcc-5 g++-5

# add realsense2
RUN apt-key adv --keyserver keys.gnupg.net --recv-key C8B3A55A6F3EFCDE || apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C8B3A55A6F3EFCDE && \
    add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo bionic main" -u
RUN apt-get update && apt-get install -y --no-install-recommends \ 
    librealsense2-dev librealsense2-dbg
#cuda-7-5
#openjdk-7-jdk 

    # vtk qt
RUN apt-get update && apt-get install -y \
    qt5-default vtk7 libvtk7-dev \
    libvtk7-java libvtk7-jni libvtk7-qt-dev

# fix Eigen3's inlcude path
RUN ln -sf /usr/include/eigen3/Eigen /usr/include/Eigen && \
    ln -sf /usr/include/eigen3/unsupported /usr/include/unsupported && \
    ln -s /usr/lib/python2.7/dist-packages/vtk/libvtkRenderingPythonTkWidgets.x86_64-linux-gnu.so /usr/lib/x86_64-linux-gnu/libvtkRenderingPythonTkWidgets.so && \
    ln -s /usr/bin/vtk7 /usr/bin/vtk


# compile two projects
RUN /tmp/build_scripts/compile_director.sh
RUN /tmp/build_scripts/compile_elasticfusion.sh

ENTRYPOINT bash -c "source /root/labelfusion/docker/docker_startup.sh && /bin/bash"
