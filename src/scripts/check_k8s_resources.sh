#!/usr/bin/env sh

COMPLIANT=true

render_k8s_resources() {

  if [ ! -f "$ISOPOD_FILE" ]; then
      echo "$ISOPOD_FILE not found. Specify file path with 'isopodFile' in CirclCI. More infos in compliance-orb Readme"
      exit 1
  fi

  isopod -f "$ISOPOD_FILE" deploy -e prod --dry-run
}

cleanup_and_quit() {
  rm output.json
  rm -rf /tmp/-k8s-manifest-files*

  if [ $COMPLIANT == false ];
  then
    exit 1
  fi

  exit 0
}

check_privileged_flag() {
for file in /tmp/-k8s-manifest-files*/*.yml
do
  [[ "$file" == '*.yml' && -e "$file" ]] || break
  opa eval --fail-defined -i "$file" -d opa-rules/container-privileged-flag.rego "data.kubernetes.validating.privileged" > output.json;

  RESULT=$(jq .result[].expressions[].value.deny[] < output.json)

  if [ -n "$RESULT" ];
  then
    echo "Non compliance detected: $RESULT"
    COMPLIANT=false
  fi
done

return 0
}

render_k8s_resources
check_privileged_flag
cleanup_and_quit





