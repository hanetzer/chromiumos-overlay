# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Library for handling building of ChromiumOS packages
#

# @ECLASS-VARIABLE: CROS_WORKON_SRCROOT
# @DESCRIPTION:
# Directory where chrome third party and platform sources are located (formerly CHROMEOS_ROOT)
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

# Calculate path where code should be checked out.
get_path() {
	local path

	if [[ -n "${CROS_WORKON_SRCROOT}" ]]; then
		path="${CROS_WORKON_SRCROOT}"
	elif [[ -n "${CHROMEOS_ROOT}" ]]; then
		path="${CHROMEOS_ROOT}"
	else
		# HACK: figure out the missing legacy path for now
		# this only happens in amd64 chroot with sudo emerge
		path="/home/${SUDO_USER}/trunk"
	fi

	if [[ "${CATEGORY}" == "chromeos-base" ]] ; then
		path+=/src/platform
	else
		path+=/src/third_party
	fi

	if [[ -n "${CROS_WORKON_LOCALNAME}" ]]; then
		path+="/${CROS_WORKON_LOCALNAME}"
	fi
	if [[ -n "${CROS_WORKON_SUBDIR}" ]]; then
		path+="/${CROS_WORKON_SUBDIR}"
	fi
	echo ${path}
}

cros-workon_src_unpack() {
	local fetch_method # local|git

	case ${PV} in
	(9999)
		fetch_method=local
		;;
	(*)
		if [[ -z "${CROS_WORKON_SRCROOT}" ]]; then # old workflow
			fetch_method=local
			# HACK: this needs to go away with the transition to new workflow
			# and also the same thing below
			DONTFETCH=1
		else # new workflow
			fetch_method=git
		fi
		;;
	esac

	# Hack
	# TODO(msb): remove once we've resolved the include path issue
	# http://groups.google.com/a/chromium.org/group/chromium-os-dev/browse_thread/thread/5e85f28f551eeda/3ae57db97ae327ae
	ln -s "${S}" "${WORKDIR}/${CROS_WORKON_LOCALNAME}"

	local repo=${CROS_WORKON_REPO}
	local project=${CROS_WORKON_PROJECT}

	if [[ "${fetch_method}" == "git" ]] ; then
		EGIT_REPO_URI="${repo}/${project}"
		EGIT_COMMIT=${CROS_WORKON_COMMIT}
		# clones to /var, copies src tree to the /build/<board>/tmp
		git_src_unpack
		return
	fi

	local path=$(get_path)

	einfo "Using local source dir: $path"

	# Clone from the git host + repository path specified by
	# CROS_WORKON_REPO + CROS_WORKON_PROJECT. Checkout source from
	# the branch specified by CROS_WORKON_COMMIT into the workspace path.
	# If the repository exists just punt and let it be copied off for build.
	if [[ "${fetch_method}" == "local" && ! -d ${path} ]] ; then
		# HACK: this needs to go away with the transition to new workflow
		if [[ "${DONTFETCH}" == "1" ]]; then
			ewarn "Sources are missing in ${path}"
			die "Are you using the new layout without CROS_WORKON_SRCROOT?"
		fi

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

cros-workon_pkg_info() {
	local CROS_WORKON_SRCDIR=$(get_path)

	for var in CROS_WORKON_SRCDIR ; do
		echo ${var}=\"${!var}\"
	done
}

EXPORT_FUNCTIONS src_unpack pkg_info
