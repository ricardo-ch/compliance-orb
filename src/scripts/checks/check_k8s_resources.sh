#!/usr/bin/env bash

CHECK_NAME="k8s-resources"
PENALTY_SCORE=20
set -o nounset
set -x

write_result() {
  app_name=$1
  check_name=$2
  penalty_score=$3
  compliance=$4

  [ -d "/tmp/$app_name" ] || mkdir "/tmp/$app_name"

  jq --null-input \
    --arg checkname "$check_name" \
    --arg penaltyScore "$penalty_score" \
    --arg compliant "$compliance" \
    '{"check_name": $checkname, "compliant": $compliant, "penalty_score": $penaltyScore}' \
    >"/tmp/$app_name/$CHECK_NAME-check.json"
}

render_k8s_resources() {
  isopod_file=$1
  app_name=$2

  # Ignore error of missing context. Command only needs to render new resources and doesn't care about already deployed
  isopod -f "$isopod_file" deploy -e prod --dry-run 2> /dev/null || true
  echo "Info: Created:"
  ls  /tmp/"$app_name"-k8s-manifest-files*/*.yml
}

write_rego_file() {

cat <<EOT >> container-privileged-flag.rego
package kubernetes.validating.privileged

deny[msg] {
  some c
  input_container[c]
  c.securityContext.privileged
  msg := sprintf("Container '%v' should not run in privileged mode.", [c.name])
}

input_container[container] {
  container := input.spec.template.spec.containers[_]
}

input_container[container] {
  container := input.spec.template.spec.initContainers[_]
}
EOT
}

cleanup_and_quit() {
  rm -f output.json
  rm -rf /tmp/-k8s-manifest-files*
}

check_privileged_flag() {
  app_name=$1
  compliance="true"

  for file in /tmp/"$app_name"-k8s-manifest-files*/*.yml
  do
    opa eval -i "$file" -d container-privileged-flag.rego "data.kubernetes.validating.privileged" > output.json;
    RESULT=$(jq .result[]?.expressions[]?.value.deny[]? < output.json)

    if [ -n "$RESULT" ];
    then
      echo "Non compliance detected: $RESULT"
      compliance="false"  
      break
    fi
  done
  write_result "$app_name" "$CHECK_NAME" $PENALTY_SCORE $compliance
}


write_rego_file
isopod_files=$(find . -regextype sed -regex ".*isopod.*\.yml")

for file in $isopod_files; do

  application=$(yq .metadata.labels.app "$file")
  render_k8s_resources "$file" "$application"
  check_privileged_flag "$application"

done


cleanup_and_quit





