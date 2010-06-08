# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Library for handling building of ChromiumOS packages
#

# @ECLASS-VARIABLE: CROS_WORKON_SRCROOT
# @DESCRIPTION:
# Directory where git repositories of packages are checked out
: ${CROS_WORKON_PROJECT:=}

# @ECLASS-VARIABLE: CROS_WORKON_REPO
# @DESCRIPTION:
# Git URL which is prefixed to CROS_WORKON_PROJECT
: ${CROS_WORKON_REPO:=http://src.chromium.org/git}

# @ECLASS-VARIABLE: CROS_WORKON_PROJECT
# @DESCRIPTION:
# Git project name which is suffixed to CROS_WORKON_REPO
: ${CROS_WORKON_PROJECT:=${PN}}}

# @ECLASS-VARIABLE: CROS_WORKON_COMMIT
# @DESCRIPTION:
# Git commit to checkout to
: ${CROS_WORKON_COMMIT:=master}

inherit git

cros-workon_src_unpack() {
	local project=${CROS_WORKON_PROJECT}
	local repo=${CROS_WORKON_REPO}
	local srcroot

	if [ -z "${CROS_WORKON_SRCROOT}" ] ; then
		if [[ "${CATEGORY}" == "chromeos-base" ]] ; then
			srcroot="${CHROMEOS_ROOT}"/src/platform
		else
			srcroot="${CHROMEOS_ROOT}"/src/third_party
		fi
	else
		srcroot="${CROS_WORKON_SRCROOT}"
	fi

	if [[ -n "${CHROMEOS_ROOT}" || "${PV}" == "9999" ]] ; then
		mkdir -p "${S}"
		cp -a "${srcroot}/${project}"/* "${S}" || die
	else
		EGIT_REPO_URI="${repo}/${project}"
		EGIT_COMMIT=${CROS_WORKON_COMMIT}
		git_src_unpack
	fi
}

EXPORT_FUNCTIONS src_unpack
