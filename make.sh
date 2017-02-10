#!/bin/bash

# this defines KF2BIN, the directory containing the Win64 KF2 directory
. local_paths.sh.in

declare -r KF2BIN_ABS_WIN="$(cygpath --windows --absolute $KF2BIN )"

hash_abbrev=$(git rev-parse --short=8 HEAD)
author_timestamp_utc=$(date -d "`git log -n 1 --pretty=format:%ai`" -u --iso-8601=seconds)
friendly_date=$(date -u '+%b %e %Y')
author=$(git log -n 1 --pretty=format:%an)
is_dev=

WSUP_TITLE="Controlled Difficulty"
WSUP_BRANDING_PICTURE="img/doubleblack.png"

if ! git diff-index --quiet HEAD -- ; then
	if [ "$1" = "deploy" ] ; then
		echo "Preparing for a dev build.  Will deploy to beta WS Item."
		set -x
		WSUP_TITLE="Controlled Difficulty Beta"
		WSUP_BRANDING_PICTURE="img/doubleblack_wrench.png"
		set +x
	fi

	hash_abbrev=DEV-"$hash_abbrev"
	author_timestamp_utc=$(date -u --iso-8601=seconds)
	is_dev=true
fi

echo '`'"define CD_COMMIT_HASH \"$hash_abbrev\"" > CD_BuildInfo.uci
echo '`'"define CD_AUTHOR_TIMESTAMP \"$author_timestamp_utc\"" >> CD_BuildInfo.uci
echo '`'"define CD_AUTHOR \"$author\"" >> CD_BuildInfo.uci

declare -r WSUP_DESCRIPTION_FILE=steam_description.txt
declare -r WSUP_DESCRIPTION="$(cat $WSUP_DESCRIPTION_FILE | sed -r 's/\"/'"'"'/g' | sed -r 's/\$MOD_VERSION/'$hash_abbrev'/; s/\$MOD_DATE/'"$friendly_date"'/' )"
declare -r WSUP_BRANDING_PICTURE_ABS_WIN=$(cygpath --windows --absolute "$WSUP_BRANDING_PICTURE" )
declare -r WSUP_SPECFILE="wsup_specfile.txt"
declare -r WSUP_SPECFILE_RELATIVE_WIN="KFGame\Src\ControlledDifficulty"\\$WSUP_SPECFILE
declare -r LINEFEED=$( echo -e '\r' )

echo Build Info:
cat CD_BuildInfo.uci
echo

cmd /C "cd /D $KF2BIN_ABS_WIN\Win64 & KFEditor.exe make -unattended -full"

if [ "$1" = "deploy" ] ; then
	declare -r WSUP_TMPDIR="$(mktemp -d)"
	declare -r WSUP_TMPDIR_ABS_WIN=$(cygpath --windows --absolute "$WSUP_TMPDIR" )

	# build workshop upload specification file

	mkdir -p "$WSUP_TMPDIR"/Unpublished/BrewedPC
	cp -a ../../Unpublished/BrewedPC/Script/ControlledDifficulty.u "$WSUP_TMPDIR"/Unpublished/BrewedPC

	cat > "$WSUP_SPECFILE" <<EOF
\$Description "$WSUP_DESCRIPTION"$LINEFEED
\$Title "$WSUP_TITLE"$LINEFEED
\$PreviewFile "$WSUP_BRANDING_PICTURE_ABS_WIN"$LINEFEED
\$Tags ""$LINEFEED
\$MicroTxItem "false"$LINEFEED
\$PackageDirectory "$WSUP_TMPDIR_ABS_WIN"$LINEFEED
EOF

	cd "$KF2BIN"

	echo "Deploying..."

	cmd /C "cd /D $KF2BIN_ABS_WIN & WorkshopUserTool.exe $WSUP_SPECFILE_RELATIVE_WIN"

	rm -rf "$WSUP_TMPDIR"
fi
