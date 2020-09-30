# source this file in bash or zsh to make
#  NETFOUNDRY_API_TOKEN 
# available to processes run in the same shell

_get_nf_token(){
    set -o pipefail
    [[ $# -eq 3 ]] || {
        echo "ERROR: send params: client_id client_secret oauth_url" >&2
        return 1
    }
    client_id=$1
    client_secret=$2
    oauth_url=$3                                              #https://netfoundry-sandbox-hnssty.auth.us-east-1.amazoncognito.com/oauth2/token
    mop_env=${oauth_url#https://netfoundry-}                  #sandbox-hnssty.auth.us-east-1.amazoncognito.com/oauth2/token
    mop_env=${mop_env%%-*.amazoncognito.com/oauth2/token}     #sandbox
    access_token=$(
        http --check-status --form --auth "${client_id}:${client_secret}" POST $oauth_url \
            "scope=https://gateway.${mop_env}.netfoundry.io//ignore-scope" \
            "grant_type=client_credentials" | jq -r .access_token
    ) || return 1
    echo ${access_token}
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

