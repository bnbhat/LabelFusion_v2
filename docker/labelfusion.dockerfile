#FROM nvidia/cuda:8.0-devel-ubuntu16.04

# ubuntu 18.04 only support cuda9.2 with tesla,
#FROM nvidia/cudagl:9.2-devel-ubuntu18.04
ianre657/ros-melodic-desktop-full-nvidia:latest

WORKDIR /root

#COPY install_dependencies.sh /tmp
#RUN /tmp/install_dependencies.sh

# COPY compile_all.sh /tmp
# RUN /tmp/compile_all.sh

ENTRYPOINT bash -c "source /root/labelfusion/docker/docker_startup.sh && /bin/bash"
