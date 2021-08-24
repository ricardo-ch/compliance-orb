#!/usr/bin/env sh

IMAGE=$1

is_docker_user_root() {
uid=$(docker run "$IMAGE" id -u)

if [ "$uid" == 0 ];
then
  return 1
fi

return 0
}

is_docker_user_root

