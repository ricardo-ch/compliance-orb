#!/bin/bash
set -euo pipefail

create_json_compliance_query() {
    app_name=$1

    jq --null-input \
        --arg app "$app_name" \
        --arg branch "$CIRCLE_BRANCH" \
        --arg commit_sha "$CIRCLE_SHA1" \
        --arg cc_url "$CIRCLE_BUILD_URL" \
        '{"application_name": $app, "branch": $branch, "commit_sha": $commit_sha , "ci_url": $cc_url, "checks": []}' \
        >"$app_name"_compliance_checks.json
}

append_application_checks() {
    app_name=$1

    for file in "$app_name"/*-check.json; do
        [[ -e $file ]] || break
        tmpfile=$(mktemp)

        jq ".checks[.checks| length] |= . +$(jq . "$file")" "$app_name_compliance_checks.json" >"${tmpfile}"
        cat "${tmpfile}" >"$app_name"_compliance_checks.json

    done
}

post_compliance_report() {
    app_name=$1

    curl -X POST -H "Content-Type: application/json" -d @"$app_name"_compliance-checks.json "${SRE_API_COMPLIANCE_ENDPOINT}"
}

isopod_files=$(find . -regextype sed -regex ".*isopod.*\.yml")

for file in $isopod_files; do
    app_name=$(yq .metadata.labels.app "$file")
    create_compliance_query "$app_name"
    append_application_checks "$app_name"
    post_compliance_report "$app_name"
done
