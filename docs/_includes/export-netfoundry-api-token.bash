# source this file in bash or zsh to make
#  NETFOUNDRY_API_TOKEN 
# available to processes run in the same shell

# troubleshooting function that drops all authentication variables
nonf(){
    unset   NETFOUNDRY_API_ACCOUNT \
            NETFOUNDRY_API_TOKEN \
            NETFOUNDRY_CLIENT_ID \
            NETFOUNDRY_PASSWORD \
            NETFOUNDRY_PASSWORD
}

_get_nf_token(){
    set -o pipefail
    [[ $# -eq 3 ]] || {
        echo "ERROR: send params: client_id client_pass oauth_url" >&2
        return 1
    }
    client_id=$1
    client_pass=$2
    oauth_url=$3                                              #https://netfoundry-sandbox-hnssty.auth.us-east-1.amazoncognito.com/oauth2/token
    mop_env=${oauth_url#https://netfoundry-}                  #sandbox-hnssty.auth.us-east-1.amazoncognito.com/oauth2/token
    mop_env=${mop_env%%-*.amazoncognito.com/oauth2/token}     #sandbox
    access_token=$(curl \
        --silent \
        --show-error \
        --fail \
        --request POST \
        --user "${client_id}:${client_pass}" \
        ${oauth_url} \
        --header 'content-type: application/x-www-form-urlencoded' \
        --data "grant_type=client_credentials&scope=https%3A%2F%2Fgateway.${mop_env}.netfoundry.io%2F%2Fignore-scope" \
            | python -c 'import json,sys;print(json.load(sys.stdin)["access_token"]);'
    ) || return 1
    echo ${access_token}
}

_get_api_account(){
    [[ -s ${NETFOUNDRY_API_ACCOUNT:=~/.netfoundry/credentials.json} ]] && {
        echo "WARN: using API account from file $NETFOUNDRY_API_ACCOUNT" >&2
    } || {
        echo "ERROR: missing API account credentials file i.e. NETFOUNDRY_API_ACCOUNT or ~/.netfoundry/credentials.json" >&2
        return 1
    }
    for TOKEN in NETFOUNDRY_CLIENT_ID NETFOUNDRY_PASSWORD NETFOUNDRY_OAUTH_URL; do
        printf '%s="%s"\n' \
            $TOKEN \
            $(python -c '
import json,sys;
varmap = {
    "NETFOUNDRY_CLIENT_ID": "clientId", 
    "NETFOUNDRY_PASSWORD": "password", 
    "NETFOUNDRY_OAUTH_URL": "authenticationUrl"
}; 
print(json.load(sys.stdin)[varmap["'$TOKEN'"]]);
            ' < $NETFOUNDRY_API_ACCOUNT)
    done
}

[[ ! -z ${NETFOUNDRY_CLIENT_ID:-} && ! -z ${NETFOUNDRY_PASSWORD:-} && ! -z ${NETFOUNDRY_OAUTH_URL:-} ]] && {
    echo "WARN: using API account from environment variables for $NETFOUNDRY_OAUTH_URL" >&2
} || {
    eval $(_get_api_account)
}

[[ ! -z ${NETFOUNDRY_CLIENT_ID:-} && ! -z ${NETFOUNDRY_PASSWORD:-} && ! -z ${NETFOUNDRY_OAUTH_URL:-} ]] || {
    echo "ERROR: API account vars are required: NETFOUNDRY_CLIENT_ID, NETFOUNDRY_PASSWORD, NETFOUNDRY_OAUTH_URL" >&2
    return 1
}

NETFOUNDRY_API_TOKEN=$(_get_nf_token ${NETFOUNDRY_CLIENT_ID} ${NETFOUNDRY_PASSWORD} ${NETFOUNDRY_OAUTH_URL})

[[ ${NETFOUNDRY_API_TOKEN} =~ ^[A-Za-z0-9_=-]+\.[A-Za-z0-9_=-]+\.?[A-Za-z0-9_.+/=-]*$ ]] && {
    export NETFOUNDRY_API_TOKEN
} || {
    echo "ERROR: invalid JWT for NETFOUNDRY_API_TOKEN: '${NETFOUNDRY_API_TOKEN}'" >&2
    return 1
}

