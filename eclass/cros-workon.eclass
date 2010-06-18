# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Library for handling building of ChromiumOS packages
#

# @ECLASS-VARIABLE: CROS_WORKON_SRCROOT
# @DESCRIPTION:
# Directory where git repositories of packages are checked out
: ${CROS_WORKON_SRCROOT:=}

# @ECLASS-VARIABLE: CROS_WORKON_SUBDIR
# @DESCRIPTION:
# Sub-directory which is added to create full source checkout path
: ${CROS_WORKON_SUBDIR:=}

# @ECLASS-VARIABLE: CROS_WORKON_REPO
# @DESCRIPTION:
# Git URL which is prefixed to CROS_WORKON_PROJECT
: ${CROS_WORKON_REPO:=http://src.chromium.org/git}

# @ECLASS-VARIABLE: CROS_WORKON_PROJECT
# @DESCRIPTION:
# Git project name which is suffixed to CROS_WORKON_REPO
: ${CROS_WORKON_PROJECT:=${PN}}}

# @ECLASS-VARIABLE: CROS_WORKON_LOCALNAME
# @DESCRIPTION:
# Temporary local name in third_party
: ${CROS_WORKON_LOCALNAME:=${PN}}}

# @ECLASS-VARIABLE: CROS_WORKON_COMMIT
# @DESCRIPTION:
# Git commit to checkout to
: ${CROS_WORKON_COMMIT:=master}

inherit git

cros-workon_src_unpack() {
	# Hack
	# TODO(msb): remove once we've resolved the include path issue
	# http://groups.google.com/a/chromium.org/group/chromium-os-dev/browse_thread/thread/5e85f28f551eeda/3ae57db97ae327ae
	ln -s "${S}" "${WORKDIR}/${CROS_WORKON_LOCALNAME}"

	local repo=${CROS_WORKON_REPO}
	local project=${CROS_WORKON_PROJECT}

	if [[ -z "${CHROMEOS_ROOT}" && "${PV}" != "9999" ]] ; then
		EGIT_REPO_URI="${repo}/${project}"
		EGIT_COMMIT=${CROS_WORKON_COMMIT}
		# clones to /var, copies src tree to the /build/<board>/tmp
		git_src_unpack
		return
	fi

	# Use an existing source tree if CHROMEOS_ROOT is set or
	# clone and checkout into the existing directory layout
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


	local path="${srcroot}"
	if [ -n "${CROS_WORKON_LOCALNAME}" ]; then
		path+="/${CROS_WORKON_LOCALNAME}"
	fi
	if [ -n "${CROS_WORKON_SUBDIR}" ]; then
		path+="/${CROS_WORKON_SUBDIR}"
	fi
	einfo "Using local source dir: $path"

	# Clone from the git host + repository path specified by
	# CROS_WORKON_REPO + CROS_WORKON_PROJECT. Checkout source from
	# the branch specified by CROS_WORKON_COMMIT into the # the 
	# CROS_WORKON_SRCROOT + CROS_WORKON_LOCALNAME + CROS_WORKON_SUBDIR
	# workspace path.
	# If the repository exists just punt and let it be copied off for build.
	if [[ "${PV}" == "9999" && ! -d ${path} ]] ; then

		addwrite / 
		local old_umask="`umask`"

		einfo "Cloning ${repo}/${project}"
		einfo "   to path: ${path}"
		einfo "   branch: ${CROS_WORKON_COMMIT}"

		git clone -n "${repo}/${project}" "${path}"
		pushd "${path}" &> /dev/null
		local ref="`git symbolic-ref HEAD 2> /dev/null`"
		if [[ "${ref#refs/heads/}" != "${CROS_WORKON_COMMIT}" ]] ; then
			# switch to CROS_WORKON_COMMIT if it is not already the current HEAD
			git checkout -b ${CROS_WORKON_COMMIT} origin/${CROS_WORKON_COMMIT}
		else
			git checkout ${CROS_WORKON_COMMIT}
		fi
		popd &> /dev/null

		umask ${old_umask}
		export SANDBOX_WRITE="${SANDBOX_WRITE%%:/}"
	fi

	# Copy source tree to /build/<board>/tmp for building
	mkdir -p "${S}"
	cp -a "${path}"/* "${S}" || die "cp -a ${path}/* ${S}"
}

EXPORT_FUNCTIONS src_unpack
