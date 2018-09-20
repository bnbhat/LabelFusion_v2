#!/bin/bash
#
# Usage:  ./docker_run.sh [/path/to/data]
#
# This script calls `nvidia-docker run` to start the labelfusion
# container with an interactive bash session.  This script sets
# the required environment variables and mounts the labelfusion
# source directory as a volume in the docker container.  If the
# path to a data directory is given then the data directory is
# also mounted as a volume.
#

#image_name=robotlocomotion/labelfusion:latest
image_name=ianre657/labelfusion:new_docker


source_dir=$(cd $(dirname $0)/.. && pwd)

if [ ! -z "$1" ]; then

  data_dir=$1
  if [ ! -d "$data_dir" ]; then
    echo "directory does not exist: $data_dir"
    exit 1
  fi

  data_mount_arg="-v $data_dir:/root/labelfusion/data"
fi

xhost +
# it is required to have 
docker run -it \
  --rm \
  --runtime=nvidia \
  -e DISPLAY \
  -e XAUTHORITY \
  --privileged \
  -e QT_X11_NO_MITSHM=1 \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  --volume="$HOME/.Xauthority:/root/.Xauthority:rw" \
  -v $source_dir:/root/labelfusion $data_mount_arg \
  -v /dev/bus/usb:/dev/bus/usb \
  ianre657/labelfusion:new_docker

 # --privileged \
#  -e XDG_RUNTIME_DIR \
#  -v $XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR:rw \

# docker run -it \
#   --runtime=nvidia
#   -e DISPLAY \
#   -e QT_X11_NO_MITSHM=1 \
#   -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
#   -v $source_dir:/root/labelfusion $data_mount_arg \
#   --privileged \
#   -v /dev/bus/usb:/dev/bus/usb\
#   $image_name

xhost -
