#!/usr/bin/env bash
set -o nounset

CHECK_NAME="passwordless-sudo"
PENALTY_SCORE=20

write_result() {
  app_name=$1
  check_name=$2
  penalty_score=$3
  compliant=$4

  [ -d "$app_name" ] || mkdir "$app_name"

  jq --null-input \
    --arg checkname "$check_name" \
    --arg penaltyScore "$penalty_score" \    
    --arg compliant "$compliant" \
    '{"check_name": $checkname, "compliant": $compliant, "penalty_score": $penaltyScore}' \
    >"$app_name/$CHECK_NAME-check.json"
}


is_sudo_available() {

  sudo_path=$(docker run "$TARGET_IMAGE" which sudo)

  if [ -z "$sudo_path" ]; then
    return 1
  fi
}

get_sudo_permissions() {

  if ! is_sudo_available; then
    echo "Info: sudo binary could not be found in container"
    COMPLIANT=true
    write_result
    return 0
  fi

  # Check for passwordless sudo permissions
  sudo_permssions=$(docker run "$TARGET_IMAGE" sudo -nl)

  if echo "$sudo_permssions" | grep -q not\ allowed; then
    COMPLIANT=true
    write_result
    return 0
  else
    echo "Non compliance detected: User has passwordless sudo permissions"
    echo "$sudo_permssions"
    write_result
    return 1
  fi
}