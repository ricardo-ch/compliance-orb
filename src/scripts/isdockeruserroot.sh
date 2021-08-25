#!/usr/bin/env sh

TARGET_IMAGE=$(isopod image)

is_docker_user_root() {
uid=$(docker run "$TARGET_IMAGE" id -u)

if [ "$uid" == 0 ];
then
  return 1
fi

return 0
}

is_docker_user_root

