#!/bin/bash
set -euf -o pipefail

create_umbrella_json () {

    jq --null-input \
        --arg app "$CIRCLE_PR_REPONAME" \
        --arg branch "$CIRCLE_BRANCH" \
        --arg commit_sha "$CIRCLE_SHA1" \
        --arg cc_url "$CIRCLE_BUILD_URL" \
        '{"application": $app, "branch": $branch, "commit_sha": $commit_sha , "circleci-run-url": $cc_url, "checks": []}' \
        > compliance-checks.json
}

append_checks () {    

    for file in *.=check.jsons;
    do 
        tmpfile=$(mktemp)

        jq ".checks[.checks| length] |= . +$(jq . "$file")" compliance-checks.json > "${tmpfile}"
        cat "${tmpfile}" >  compliance-checks.json

    done

}

send_data () {
    curl -X POST -H "Content-Type: application/json" -d @compliance-checks.json http://localhost:5000
}

create_umbrella_json
append_checks
send_data