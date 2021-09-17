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

  if [ $COMPLIANT == false ];
  then
    exit 1
  fi

  echo "Info: Done"
  exit 0
}

check_privileged_flag() {
echo "Info: Validating K8S resources"
for file in /tmp/*-k8s-manifest-files*/*.yml
do
  echo "Info: Validating $file"
  opa eval --fail-defined -i "$file" -d opa-rules/container-privileged-flag.rego "data.kubernetes.validating.privileged" > output.json;

  RESULT=$(jq .result[]?.expressions[]?.value.deny[]? < output.json)

  if [ -n "$RESULT" ];
  then
    echo "Non compliance detected: $RESULT"
    COMPLIANT=false
  fi
done
echo "Info: Finished validating K8S resources"

}

render_k8s_resources
check_privileged_flag
cleanup_and_quit





