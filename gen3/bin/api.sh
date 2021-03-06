#!/bin/bash

source "${GEN3_HOME}/gen3/lib/utils.sh"
gen3_load "gen3/lib/kube-setup-init"


gen3_api_help() {
  gen3 help api
}

#
# Generate a new access token - or pull from cache if available
#
gen3_access_token() {
  local username
  username="$1"
  if [[ -z "$username" ]]; then
    gen3_api_help
    return 1
  fi

  local gen3CredsCache="${GEN3_CACHE_DIR}/${username}_access_token.json"
  if [[ -f "$gen3CredsCache" ]]; then
    local expTime
    local nowTime
    nowTime=$(date '+%s')
    expTime=$(cat "$gen3CredsCache" | awk -F . '{ print $2 }' | base64 --decode 2> /dev/null | jq -r .exp)
    if [[ $((nowTime + 300)) -lt "$expTime" ]]; then # cache not out of date
      echo -e "INFO: using cached token at $gen3CredsCache" 1>&2
      cat $gen3CredsCache
      return $?
    fi
  fi
  g3kubectl exec $(gen3 pod fence) -- fence-create token-create --scopes openid,user,fence,data,credentials,google_service_account --type access_token --exp 3600 --username ${username} | tail -1 | tee "$gen3CredsCache"
  return $?
}


#
# Little helper that acquires an access token
#
# @param path {string} below path
# @param user {string} to get access token for
# @param jsonFile {string} path to file to post - GET instead of POST if jsonFile is ""
#
gen3_curl_json() {
  local path
  local userName
  local hostname
  local accessToken
  local jsonFile
  local method

  method="POST"
  jsonFile=""
  if [[ $# -lt 2 || -z "$1" ]]; then
    echo -e "$(red_color "ERROR: USE: gen3_curl_json path username jsonFile")" 2>1
    return 1
  fi
  path="$1"
  shift
  userName="$1"
  shift
  if [[ $# -gt 0 ]]; then
    jsonFile="$1"
    shift
    if [[ ! -f "$jsonFile" ]]; then
      echo -e "$(red_color "ERROR: unable to read json file $jsonFile")"
      return 1
    fi
  else
    method="GET"
  fi
  accessToken="$(gen3_access_token "$userName")"
  if [[ -z "$accessToken" ]]; then
    echo -e "$(red_color "ERROR: unable to acquire token for $userName")"
    return 1
  fi
  hostname="$(g3kubectl get configmap manifest-global -o json | jq -r '.data["hostname"]')"
  if [[ -z "$hostname" ]]; then
    echo -e "$(red_color "ERROR: unable to determine hostname for commons API")"
    return 1
  fi

  if [[ "$method" == "POST" ]]; then
    curl -s -X POST "https://$hostname/$path" -H "Authorization: bearer $accessToken" -H "Content-Type: application/json" "-d@$jsonFile"
  else
    curl -s -X GET "https://$hostname/$path" -H "Authorization: bearer $accessToken"
  fi
  return $?
}


#
# Post a new project to the environment
#
# @param progName
# @parm projName
# @param userName
gen3_new_project() {
  local jsonFile
  local userName
  local projName
  local progName
  local result

  if [[ $# -lt 3 || -z "$1" || -z "$2" || -z "$3" ]]; then
    echo -e "$(red_color "ERROR: USE: gen3 api new-project prog-name proj-name username")" 2>1
    return 1
  fi
  progName="$1"
  shift
  projName="$1"
  shift
  userName="$1"
  shift
  jsonFile="$(mktemp -p "$XDG_RUNTIME_DIR" proj.json_XXXXXX)"
  cat - > "$jsonFile" <<EOM
{
  "type": "project",
  "code": "$projName",
  "name": "$projName",
  "dbgap_accession_number": "$projName",
  "state": "open",
  "releasable": true
}
EOM
  gen3_curl_json "/api/v0/submission/$progName" "$userName" "$jsonFile"
  result=$?
  rm $jsonFile
  return $result
}


#
# Post a new program to the environment
#
# @parm progName
# @param userName
#
gen3_new_program() {
  local jsonFile
  local userName
  local progName
  local result

  if [[ $# -lt 2 || -z "$1" || -z "$2" ]]; then
    echo -e "$(red_color "ERROR: USE: gen3 api new-program prog-name username")" 2>1
    return 1
  fi
  progName="$1"
  shift
  userName="$1"
  shift
  jsonFile="$(mktemp -p "$XDG_RUNTIME_DIR" proj.json_XXXXXX)"
  cat - > "$jsonFile" <<EOM
{
  "name": "$progName",
  "type": "program",
  "dbgap_accession_number": "$progName"
}
EOM
  gen3_curl_json "/api/v0/submission/" "$userName" "$jsonFile"
  result=$?
  rm $jsonFile
  return $result
}


gen3_indexd_post_folder_help() {
  cat - <<EOM
  gen3 indexd-post-folder [folder]:
      Post the .json files under the given folder to indexd
      in the current environment: $DEST_DOMAIN
      Note - currently only works with new records - does not
         attempt to update existing records.
EOM
  return 0
}

gen3_indexd_post_folder() {
  local DEST_DOMAIN
  local DEST_DIR
  local INDEXD_USER
  local INDEXD_SECRET

  DATA_DIR="$1"

  if [[ -z "${DATA_DIR}" || "${DATA_DIR}" =~ ^-*h(elp)?$ ]]; then
    gen3_indexd_post_folder_help
    return 0
  fi

  if [[ ! -d "${DATA_DIR}" ]]; then
    echo -e "$(red_color "ERROR: ") DATA_DIR, ${DATA_DIR}, does not exist"
    gen3_indexd_post_folder_help
    return 1
  fi

  DEST_DOMAIN=$(g3kubectl get configmap global -o json | jq -r '.data.hostname')
  INDEXD_USER=gdcapi
  # grab the gdcapi indexd password from sheepdog creds
  INDEXD_SECRET="$(g3kubectl get secret sheepdog-creds -o json | jq -r '.data["creds.json"]' | base64 --decode | jq -r '.indexd_password')"

  ls -1f "${DATA_DIR}" | while read -r name; do 
    if [[ $name =~ .json$ ]]; then
      echo $name; 
      curl -i -u "${INDEXD_USER}:$INDEXD_SECRET" -H "Content-Type: application/json" -d @"$DATA_DIR/$name" "https://${DEST_DOMAIN}/index/index/"
      echo --------------------; 
      echo ---------------; 
    fi
  done
}


#---------- main

if [[ -z "$GEN3_SOURCE_ONLY" ]]; then
  # Support sourcing this file for test suite
  command="$1"
  shift
  case "$command" in
    "indexd-post-folder")
      gen3_indexd_post_folder "$@"
      ;;
    "access-token")
      gen3_access_token "$@"
      ;;
    "new-program")
      gen3_new_program "$@"
      ;;
    "new-project")
      gen3_new_project "$@"
      ;;
    "curl")
      gen3_curl_json "$@"
      ;;
    *)
      gen3_api_help
      ;;
  esac
fi
