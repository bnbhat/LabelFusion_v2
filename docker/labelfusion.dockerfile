FROM ianre657/ros-kinetic-xenial-qt4vtk5

# The taraget environment is VTK7.1.1 + Qt4.8.7

WORKDIR /root


COPY build_scripts /tmp/build_scripts

# unknown
# libboost-all-dev libopencv-dev libqhull-dev

RUN apt-get update && apt-get upgrade -y
# install_dependencies
    # basic packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils && apt-get install  -y --no-install-recommends \
    sudo git bash-completion lsb-core wget software-properties-common
    # for debuuging
RUN apt-get update && apt-get install -y --no-install-recommends \
  cmake-curses-gui vim apt-file \
  && apt-file update 

    # dependency for Director
RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential cmake libglib2.0-dev libqt4-dev \
  libx11-dev libxext-dev libxt-dev \
  python-dev python-lxml python-numpy python-scipy python-yaml python-vtk  \
  libvtk5-qt4-dev libvtk5-dev \
  libqwt-dev openjdk-8-jdk qtbase5-private-dev \
  libboost-all-dev libeigen3-dev liblua5.2-dev libyaml-cpp-dev libopencv-dev libqhull-dev 

    # dependency for ElasticFusion
RUN apt-get update && apt-get install -y --no-install-recommends \
  git libsuitesparse-dev cmake-qt-gui build-essential libusb-1.0-0-dev libudev-dev \
  freeglut3-dev libglew-dev libeigen3-dev zlib1g-dev libjpeg-dev libopenni2-dev \
  gcc-5 g++-5

# add realsense2
RUN apt-key adv --keyserver keys.gnupg.net --recv-key C8B3A55A6F3EFCDE || apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C8B3A55A6F3EFCDE && \
    add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo xenial main" -u
RUN apt-get update && apt-get install -y --no-install-recommends \ 
    librealsense2-dev librealsense2-dbg


# fix Eigen3's inlcude path
RUN ln -sf /usr/include/eigen3/Eigen /usr/include/Eigen && \
    ln -sf /usr/include/eigen3/unsupported /usr/include/unsupported && \
    ln -s /usr/lib/python2.7/dist-packages/vtk/libvtkRenderingPythonTkWidgets.x86_64-linux-gnu.so /usr/lib/x86_64-linux-gnu/libvtkRenderingPythonTkWidgets.so && \
    ln -s /usr/local/cuda-8.0 /usr/local/cuda

# compile two projects


# compile director
#RUN /tmp/build_scripts/compile_director.sh
RUN git clone -b labelFusion-director https://github.com/ianre657/director.git \
    && mkdir director-build && cd director-build \
    && cmake ../director/distro/superbuild \
        -DUSE_EXTERNAL_INSTALL:BOOL=ON \
        -DUSE_DRAKE:BOOL=OFF \
        -DUSE_LCM:BOOL=ON \
        -DUSE_LIBBOT:BOOL=ON \
        -DUSE_SYSTEM_EIGEN:BOOL=ON \
        -DUSE_SYSTEM_LCM:BOOL=OFF \
        -DUSE_SYSTEM_LIBBOT:BOOL=OFF \
        -DUSE_SYSTEM_VTK:BOOL=ON \
        -DUSE_PCL:BOOL=ON \
        -DUSE_APRILTAGS:BOOL=OFF \
        -DUSE_KINECT:BOOL=ON \

        -DCMAKE_INSTALL_PREFIX:PATH=/root/install \
        -DCMAKE_BUILD_TYPE:STRING=Release \
        -DDD_QT_VERSION:STRING=4 \
    && make -j"$(nproc)" -l"$(nproc)"

# compile elasticfusion
RUN /tmp/build_scripts/compile_elasticfusion.sh

ENTRYPOINT bash -c "source /root/labelfusion/docker/docker_startup.sh && /bin/bash"
