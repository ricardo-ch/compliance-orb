#!/usr/bin/env sh

TARGET_IMAGE=$(isopod image)

is_sudo_available() {

sudo_path=$(docker run "$TARGET_IMAGE" command -v sudo)

if [ -z $sudo_path ];
then
    echo "sudo could not be found"
    exit 0
fi

}

get_sudo_permissions() {

# Check for passwordless sudo permissions
sudo_permssions=$(docker run "$TARGET_IMAGE" sudo -nl)

if $(echo "$sudo_permssions" | grep -q not\ allowed);
then
  echo "User doesn't have passwordless sudo permissions"
  return 0
else
  echo "User has passwordless sudo permissions"
  echo "$sudo_permssions"
  return 1
fi

}

is_sudo_available
get_sudo_permissions

