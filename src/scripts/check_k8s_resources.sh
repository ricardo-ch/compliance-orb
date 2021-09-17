#!/usr/bin/env sh

COMPLIANT=true

render_k8s_resources() {

  echo "Info: starting rendering"

  if [ ! -f "$ISOPOD_FILE" ]; then
      echo "$ISOPOD_FILE not found. Specify file path with 'isopodFile' in CirclCI. More infos in compliance-orb Readme"
      exit 1
  fi

  # ignore error of missing context. Command only needs to render new resources and doesn't care about already deployed
  isopod -f "$ISOPOD_FILE" deploy -e prod --dry-run || true

  echo "Info: rendering finished"
}

cleanup_and_quit() {

  echo "Info: Cleaning up"
  rm output.json
  rm -rf /tmp/-k8s-manifest-files*

  if [ $COMPLIANT = false ];
  then
    exit 1
  fi

  echo "Info: Done"
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
echo "Info: Validating K8S resources"
for file in /tmp/*-k8s-manifest-files*/*.yml
do
  echo "Info: Validating $file"

  echo "Debug: Exit code $?"
  opa eval -i "$file" -d container-privileged-flag.rego "data.kubernetes.validating.privileged"
  echo "Debug: Exit code $?"
  opa eval -i "$file" -d container-privileged-flag.rego "data.kubernetes.validating.privileged" > output.json;
  echo "Debug: Exit code $?"

  RESULT=$(jq .result[]?.expressions[]?.value.deny[]? < output.json)
  echo "Debug: Exit code $?"

  if [ -n "$RESULT" ];
  then
    echo "Non compliance detected: $RESULT"
    COMPLIANT=false
  fi
  echo "Debug: Exit code $?"
done
echo "Info: Finished validating K8S resources"

}

render_k8s_resources
write_rego_file
check_privileged_flag
cleanup_and_quit





