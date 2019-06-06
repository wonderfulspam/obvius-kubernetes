#!/usr/bin/env bash
set -e
CONFIG_FILE="build_config.json"
BASE_URL=$(jq -r '.base_url' "$CONFIG_FILE")
CATALOG_URL=$(jq -r '.catalog_url' "$CONFIG_FILE")
TAG_LIST_SUFFIX=$(jq -r '.tag_list_uri' "$CONFIG_FILE")

if [[ -z "$1" ]]; then
    echo "###USAGE###"
    echo "Push \"latest\" tag as well as new version:"
    echo "./build_tag_and_push <image_name>"
    echo ""
    echo "Push new version but skip \"latest\":"
    echo "./build_tag_and_push <image_name> 1"
    echo ""
    echo "List versions:"
    echo "./build_tag_and_push list_versions"
    exit 0
fi

if [[ -z "$DOCKERREG_USER" ]] || [[ -z "$DOCKERREG_PW" ]]; then
   echo "Please export DOCKERREG_USER and DOCKERREG_PW env variables before proceeding"
   exit 0
fi
CREDENTIALS="$DOCKERREG_USER:$DOCKERREG_PW"

STATUS=$(curl -s -w %{http_code} -o /dev/null --user "$CREDENTIALS" "https://$CATALOG_URL")
if [[ ! "$STATUS" -eq 200 ]]; then
   echo "Your dockerreg credentials are invalid, aborting"
   exit 0
fi

get_current_version () {
  local CURRENT_VERSION=$(curl -s --user "$CREDENTIALS" "https://$CATALOG_URL$1$TAG_LIST_SUFFIX" | jq -r '[ .tags[] ] | map(select(. != "latest" and . != "dev")) | max')
  echo "$CURRENT_VERSION"
}

get_versions () {
    for row in $(jq -rc '.images | to_entries[] | .value.uri' "$CONFIG_FILE")
    do
        local VERS="$(get_current_version $row)"
        echo "$row: $VERS"
    done
}

if [[ "$1" == "list_versions" ]]; then
    get_versions
    exit 0
fi

build_and_tag () {
    local IMAGE=$1
    local SKIP_LATEST=$2
    local DIR=$(jq -r ".images.\"$1\".directory | select (.!=null)" "$CONFIG_FILE")
    local URI=$(jq -r ".images.\"$1\".uri | select (.!=null)" "$CONFIG_FILE")
    if [[ -z "$DIR" ]]; then
        echo "$IMAGE is not listed in the config file."
        echo ""
        echo "These are the images and directories I am aware of:"
        jq -r '.images | keys[] as $k | "\($k) \(.[$k] | .directory)"' "$CONFIG_FILE"
        echo ""
        for SUGGESTION in $(jq -r ".images | with_entries( select(.key|contains(\"$IMAGE\"))) | keys[] | select (.!=null)" "$CONFIG_FILE")
        do
            echo "Did you mean $SUGGESTION?"
        done
        exit 0
    fi
    if [[ -z "$URI" ]]; then
        echo "No uri specified for $IMAGE, aborting"
        exit 0
    fi
    if [[ ! -f "$DIR/CHANGELOG" ]]; then
        echo "No CHANGELOG found in $DIR, aborting"
        exit 0
    fi
    local VERSION=$(head -n 1 "$DIR/CHANGELOG" | sed 's/[][]//g')
    local REMOTE_VERSION=$(get_current_version "$URI")

   echo -n "You are about to build $IMAGE from $DIR. Your specified version is $VERSION and the latest remote version is $REMOTE_VERSION. Are you happy with this? [Y/n] "
   read OK;
   if [[ "${OK}" == "" ]] || [[ "${OK}" == "y" ]] || [[ "${OK}" == "Y" ]]; then
        docker build "$DIR" -q -t "$IMAGE:latest"
        local IMAGE_TAG="$BASE_URL$URI"
        docker tag ${IMAGE} ${IMAGE_TAG}:${VERSION}
        echo "Created $IMAGE_TAG:$VERSION tag"
        if [[ -z "$SKIP_LATEST" ]]; then
           docker tag ${IMAGE} ${IMAGE_TAG}:latest
           echo "Created $IMAGE_TAG:latest tag"
        fi
        docker push ${IMAGE_TAG}:${VERSION} &> /dev/null
        echo "Pushed $IMAGE_TAG:$VERSION"
        if [[ -z "$SKIP_LATEST" ]]; then
           docker push ${IMAGE_TAG}:latest &> /dev/null
           echo "Pushed $IMAGE_TAG:latest"
        fi
   fi
}

build_and_tag $1 $2
