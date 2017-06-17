#!/bin/bash

set -e
set -u

GH_RELEASE_TMP=gh-release-tmp

mkdir -p "${GH_RELEASE_TMP}"

cat > "${GH_RELEASE_TMP}"/create_release.json <<EOF
{
  "tag_name": "${CD_TAG_NAME}",
  "target_commitish": "$(git rev-parse HEAD)",
  "name": "${CD_RELEASE_NAME}",
  "body": "",
  "draft": true,
  "prerelease": ${CD_IS_PRERELEASE}
}
EOF

curl -n --netrc-file ~/.netrc -X POST \
	-H 'Content-Type: application/json' \
	-d @"${GH_RELEASE_TMP}"/create_release.json \
	https://api.github.com/repos/notblackout/kf2-controlled-difficulty/releases > "${GH_RELEASE_TMP}"/release_response.json

CD_U_FILE=../../Unpublished/BrewedPC/Script/ControlledDifficulty.u
CD_U_UPLOAD_URL=$( jq .upload_url "${GH_RELEASE_TMP}"/release_response.json | sed -r 's/^"//; s/"$//; s/\{.*\}//' )?name=ControlledDifficulty.u

curl -n --netrc-file ~/.netrc -X POST \
	-H 'Content-Type: application/octet-stream' \
	-H 'Accept: application/json' \
	--data-binary @"${CD_U_FILE}" \
	"${CD_U_UPLOAD_URL}" > "${GH_RELEASE_TMP}"/asset_response.json
