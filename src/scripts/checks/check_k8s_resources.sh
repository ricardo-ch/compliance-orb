#!/usr/bin/env sh

CHECK_NAME="k8s-resources"
PENALTY_SCORE=20
COMPLIANT=false

write_result() {

  jq --null-input \
    --arg checkname "$CHECK_NAME" \
    --arg compliant "$COMPLIANT" \
    --arg penaltyScore "$PENALTY_SCORE" \
      '{"compliance-check-name": $checkname, "compliant": $compliant, "penalty-score": $penaltyScore}' \
    > "$CHECK_NAME-check.json"
}


render_k8s_resources() {

  if [ ! -f "$ISOPOD_FILE" ]; then
      echo "$ISOPOD_FILE not found. Specify file path with 'isopodFile' in CirclCI. More infos in compliance-orb Readme"
      exit 1
  fi

  # ignore error of missing context. Command only needs to render new resources and doesn't care about already deployed
  isopod -f "$ISOPOD_FILE" deploy -e prod --dry-run 2> /dev/null || true
  echo "Info: Created:"
  ls  /tmp/*-k8s-manifest-files*/*.yml
}

cleanup_and_quit() {

  rm output.json
  rm -rf /tmp/-k8s-manifest-files*

  if [ $COMPLIANT = false ];
  then

    exit 1
  fi

  exit 0
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

check_privileged_flag() {

for file in /tmp/*-k8s-manifest-files*/*.yml
do

  opa eval -i "$file" -d container-privileged-flag.rego "data.kubernetes.validating.privileged" > output.json;
  RESULT=$(jq .result[]?.expressions[]?.value.deny[]? < output.json)

  if [ -n "$RESULT" ];
  then
    echo "Non compliance detected: $RESULT"
  else
    COMPLIANT=true
  fi

done

}

render_k8s_resources
write_rego_file
check_privileged_flag
write_result
cleanup_and_quit





