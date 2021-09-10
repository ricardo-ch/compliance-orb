#!/usr/bin/env sh

if [ -z "${IMAGE_NAME}" ];
then
  TARGET_IMAGE=$(isopod image)
else
  TARGET_IMAGE="${IMAGE_NAME}"
fi

is_docker_user_root() {
uid=$(docker run "$TARGET_IMAGE" id -u)

if [ "$uid" == 0 ];
then
  echo "Non compliance detected: Container is using Root user"
  return 1
fi

return 0
}

is_sudo_available() {
sudo_path=$(docker run "$TARGET_IMAGE" which sudo)

if [ -z "$sudo_path" ];
then
    return 1
fi
}

get_sudo_permissions() {

if ! is_sudo_available;
  then
  echo "Info: sudo binary could not be found in container"
  return 0
fi

# Check for passwordless sudo permissions
sudo_permssions=$(docker run "$TARGET_IMAGE" sudo -nl)

if echo "$sudo_permssions" | grep -q not\ allowed;
then
  return 0
else
  echo "Non compliance detected: User has passwordless sudo permissions"
  echo "$sudo_permssions"
  return 1
fi
}

is_docker_user_root
get_sudo_permissions

