#/bin/bash
set -euf -o pipefail

createUmbrellaJson () {

    DATE=$(date +%Y-%M-%d)
    BRANCH="maste"
    APP="spa"
    CC_URL="http://blabla.com"

    jq --null-input \
        --arg date "$DATE" \
        --arg branch "$BRANCH" \
        --arg app "$APP" \
        --arg cc_url "$CC_URL" \
        '{"application": $app, "branch": $branch, "timestamp": $date, "circleci-run-url": $cc_url, "checks": []}' \
        > compliance-checks.json
}

appendChecks () {    

    for file in $(ls check-jsons);
    do 
        tmpfile=$(mktemp)

        jq ".checks[.checks| length] |= . +$(jq . check-jsons/$file)" compliance-checks.json > ${tmpfile}
        cat ${tmpfile} >  compliance-checks.json

    done

}

sendData () {
    curl -X POST -H "Content-Type: application/json" -d @compliance-checks.json $SRE_API_URL
}

createUmbrellaJson
appendChecks
sendData