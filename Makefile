# This defines KF2BIN, the directory containing the Win64 KF2 directory
include local_paths.mk

#
# Variables and constants
#

KF2BIN_ABS_WIN     := $(shell cygpath --windows --absolute "$(KF2BIN)")
GIT_HASH_ABBREV    := $(shell git rev-parse --short=6 HEAD)
GIT_AUTHOR         := $(shell git log -n 1 --pretty=format:%an)
GIT_RAW_TIMESTAMP  := $(shell git log -n 1 --pretty=format:%ai)
GIT_UTC_TIMESTAMP  := $(shell date -d "$(GIT_RAW_TIMESTAMP)" -u --iso-8601=seconds)
BUILD_TYPE         := Rel
FRIENDLY_DATE      := $(shell date -u '+%b %e %Y')

IS_RELEASE               := true
IS_WORKING_DIR_DIRTY     := $(shell git diff-index --quiet HEAD -- ; echo $?)
CURRENT_COMMIT_TAG_COUNT := $(shell git tag -l --points-at HEAD | wc -l)

LINEFEED           := $(shell echo -e '\r')

WSUP_TITLE                      := Controlled Difficulty
WSUP_BRANDING_PICTURE           := img/doubleblack.png
WSUP_DESCRIPTION_FILE           := steam_description.txt
WSUP_SPECFILE                   := wsup_specfile.txt

wsup_specfile.txt : WSUP_TMPDIR           := $(shell mktemp -d)
wsup_specfile.txt : WSUP_TMPDIR_ABS_WIN   := $(shell cygpath --windows --absolute "$(WSUP_TMPDIR)")

# If the git working directory has changes, tweak the version string
# and branding information for the workshop item
ifeq ($(CURRENT_COMMIT_TAG_COUNT),0)
	IS_RELEASE              := false
	WSUP_TITLE              := Controlled Difficulty Beta
	WSUP_BRANDING_PICTURE   := img/doubleblack_wrench.png
	GIT_UTC_TIMESTAMP       := $(shell date -u --iso-8601=seconds)
	BUILD_TYPE              := BETA
endif
ifeq ($(IS_WORKING_DIR_DIRTY),0)
	IS_RELEASE              := false
	WSUP_TITLE              := Controlled Difficulty Beta
	WSUP_BRANDING_PICTURE   := img/doubleblack_wrench.png
	GIT_UTC_TIMESTAMP       := $(shell date -u --iso-8601=seconds)
	BUILD_TYPE              := DEVTEST
endif

WSUP_BRANDING_PICTURE_ABS_WIN   := $(shell cygpath --windows --absolute "$(WSUP_BRANDING_PICTURE)")
WSUP_DESCRIPTION                := $(shell cat "$(WSUP_DESCRIPTION_FILE)" | sed -r 's/\"/'"'"'/g' | sed -r 's/\$$MOD_VERSION/'$(GIT_HASH_ABBREV)'/; s/\$$MOD_DATE/'"$(FRIENDLY_DATE)"'/' )"
WSUP_SPECFILE_RELATIVE_WIN      := KFGame\Src\ControlledDifficulty\$(WSUP_SPECFILE)

GIT_UTC_DATE            := $(shell echo $(GIT_UTC_TIMESTAMP) | sed 's/T.*//')

# Multiline variable for the contents of wsup_specfile.txt
define WSUP_SPECFILE_CONTENTS
$$Description "$(WSUP_DESCRIPTION)"$(LINEFEED)
$$Title "$(WSUP_TITLE)"$(LINEFEED)
$$PreviewFile "$(WSUP_BRANDING_PICTURE_ABS_WIN)"$(LINEFEED)
$$Tags ""$(LINEFEED)
$$MicroTxItem "false"$(LINEFEED)
$$PackageDirectory "$(WSUP_TMPDIR_ABS_WIN)"$(LINEFEED)
endef

# Multiline variable for the contents of CD_BuildInfo.uci
define BUILDINFO_UCI
`define CD_COMMIT_HASH "$(GIT_HASH_ABBREV)"
`define CD_BUILD_TYPE "$(BUILD_TYPE)"
`define CD_AUTHOR_TIMESTAMP "$(GIT_UTC_TIMESTAMP)"
`define CD_AUTHOR_DATE "$(GIT_UTC_DATE)"
`define CD_AUTHOR "$(GIT_AUTHOR)"
endef

#
# Targets/rules/recipes
#

.PHONY: compile deploy CD_BuildInfo.uci wsup_specfile.txt

compile: CD_BuildInfo.uci
	cmd /C 'cd /D $(KF2BIN_ABS_WIN)\Win64 & KFEditor.exe make -unattended -full'

CD_BuildInfo.uci:
	$(file > CD_BuildInfo.uci,$(BUILDINFO_UCI))

wsup_specfile.txt:
	mkdir -p "$(WSUP_TMPDIR)"/Unpublished/BrewedPC
	cp -a ../../Unpublished/BrewedPC/Script/ControlledDifficulty.u "$(WSUP_TMPDIR)"/Unpublished/BrewedPC
	$(file > wsup_specfile.txt,$(WSUP_SPECFILE_CONTENTS))

deploy: wsup_specfile.txt compile
	echo deploy target commented while testing
#	echo "Deploying..."
#	cd "$KF2BIN"
#	cmd /C 'cd /D $(KF2BIN_ABS_WIN) & WorkshopUserTool.exe $WSUP_SPECFILE_RELATIVE_WIN'
#	rm -rf "$(WSUP_TMPDIR)"
