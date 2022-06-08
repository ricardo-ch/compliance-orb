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


isopod_files=$(find . -regextype sed -regex ".*isopod.*\.yml")

for file in $isopod_files; do

  image=$(isopod image -f "$file")
  application=$(yq .metadata.labels.app "$file")

  sudo_path=$(docker run "$image" which sudo)
  if [ -z "$sudo_path" ]; then
    sudo_permissions=$(docker run "$TARGET_IMAGE" sudo -nl)
    if [ -z "$sudo_permissions" ]; then
      write_result "$application" "$CHECK_NAME" $PENALTY_SCORE "false"
      break 
    fi     
  fi
  write_result "$application" "$CHECK_NAME" $PENALTY_SCORE "true"

done