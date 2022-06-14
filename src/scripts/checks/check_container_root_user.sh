#!/usr/bin/env bash
set -o nounset

CHECK_NAME="root-user"
PENALTY_SCORE=20

write_result() {
  app_name=$1
  check_name=$2
  penalty_score=$3
  compliance=$4

  [ -d "$app_name" ] || mkdir "$app_name"

  jq --null-input \
    --arg checkname "$check_name" \
    --arg penaltyScore "$penalty_score" \
    --arg compliant "$compliance" \
    '{"check_name": $checkname, "compliant": $compliant, "penalty_score": $penaltyScore}' \
    >"/tmp/$app_name/$CHECK_NAME-check.json"
}

isopod_files=$(find . -regextype sed -regex ".*isopod.*\.yml")

for file in $isopod_files; do

  image=$(isopod image -f "$file")
  application=$(yq .metadata.labels.app "$file")

  uid=$(docker run "$image" id -u)
  if [ "$uid" == "0" ]; then
    write_result "$application" "$CHECK_NAME" $PENALTY_SCORE "false"
  else
    write_result "$application" "$CHECK_NAME" $PENALTY_SCORE "true"
  fi

done
