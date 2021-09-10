#!/usr/bin/env sh



if [ -z "${imageName}" ];
then
  TARGET_IMAGE=$(isopod image)
else
  TARGET_IMAGE="${imageName}"
fi



is_docker_user_root() {


uid=$(docker run "$TARGET_IMAGE" id -u)

if [ "$uid" == 0 ];
then
  echo "Container is using Root user"
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
  echo "sudo could not be found"
  return 0
fi

# Check for passwordless sudo permissions
sudo_permssions=$(docker run "$TARGET_IMAGE" sudo -nl)

if echo "$sudo_permssions" | grep -q not\ allowed;
then
  echo "User doesn't have passwordless sudo permissions"
  return 0
else
  echo "User has passwordless sudo permissions"
  echo "$sudo_permssions"
  return 1
fi

}



is_docker_user_root
get_sudo_permissions

