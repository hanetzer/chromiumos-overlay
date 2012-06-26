# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Library for handling building of ChromiumOS packages
#


# Array variables. All of the following variables can contain multiple items
# with the restriction being that all of them have to have either:
# - the same number of items globally
# - one item as default for all
# - no items as the cros-workon default
# The exception is CROS_WORKON_PROJECT which has to have all items specified.
ARRAY_VARIABLES=( CROS_WORKON_{SUBDIR,REPO,PROJECT,LOCALNAME,DESTDIR,COMMIT,TREE} )

# @ECLASS-VARIABLE: CROS_WORKON_SUBDIR
# @DESCRIPTION:
# Sub-directory which is added to create full source checkout path
: ${CROS_WORKON_SUBDIR:=}

# @ECLASS-VARIABLE: CROS_WORKON_REPO
# @DESCRIPTION:
# Git URL which is prefixed to CROS_WORKON_PROJECT
: ${CROS_WORKON_REPO:=http://git.chromium.org}

# @ECLASS-VARIABLE: CROS_WORKON_PROJECT
# @DESCRIPTION:
# Git project name which is suffixed to CROS_WORKON_REPO
: ${CROS_WORKON_PROJECT:=${PN}}

# @ECLASS-VARIABLE: CROS_WORKON_LOCALNAME
# @DESCRIPTION:
# Temporary local name in third_party
: ${CROS_WORKON_LOCALNAME:=${PN}}

# @ECLASS-VARIABLE: CROS_WORKON_DESTDIR
# @DESCRIPTION:
# Destination directory in ${WORKDIR} for checkout.
# Note that the default is ${S}, but is only referenced in src_unpack for
# ebuilds that would like to override it.
: ${CROS_WORKON_DESTDIR:=}

# @ECLASS-VARIABLE: CROS_WORKON_COMMIT
# @DESCRIPTION:
# Git commit to checkout to
: ${CROS_WORKON_COMMIT:=master}

# @ECLASS-VARIABLE: CROS_WORKON_TREE
# @DESCRIPTION:
# SHA1 of the contents of the repository. This is used for verifying the
# correctness of prebuilts. Unlike the commit hash, this SHA1 is unaffected
# by the history of the repository, or by commit messages.
: ${CROS_WORKON_TREE:=}

# Scalar variables. These variables modify the behaviour of the eclass.

# @ECLASS-VARIABLE: CROS_WORKON_SUBDIRS_TO_COPY
# @DESCRIPTION:
# Make cros-workon operate exclusively with the subtrees given by this array.
# NOTE: This only speeds up local_cp builds. Inplace/local_git builds are unaffected.
# It will also be disabled by using project arrays, rather than a single project.
: ${CROS_WORKON_SUBDIRS_TO_COPY:=/}

# @ECLASS-VARIABLE: CROS_WORKON_SUBDIRS_BLACKLIST
# @DESCRIPTION:
# Array of directories in the source tree to explicitly ignore and not even copy
# them over. This is intended, for example, for blocking infamous bloated and
# generated content that is unwanted during the build.
: ${CROS_WORKON_SUBDIRS_BLACKLIST:=}

# @ECLASS-VARIABLE: CROS_WORKON_SRCROOT
# @DESCRIPTION:
# Directory where chrome third party and platform sources are located (formerly CHROMEOS_ROOT)
: ${CROS_WORKON_SRCROOT:=}

# @ECLASS-VARIABLE: CROS_WORKON_LOCALGIT
# @DESCRIPTION:
# Use git to perform local copy
: ${CROS_WORKON_LOCALGIT:=}

# @ECLASS-VARIABLE: CROS_WORKON_INPLACE
# @DESCRIPTION:
# Build the sources in place. Don't copy them to a temp dir.
: ${CROS_WORKON_INPLACE:=}

# @ECLASS-VARIABLE: CROS_WORKON_USE_VCSID
# @DESCRIPTION:
# Export VCSID into the project
: ${CROS_WORKON_USE_VCSID:=}

# @ECLASS-VARIABLE: CROS_WORKON_GIT_SUFFIX
# @DESCRIPTION:
# The git eclass does not do locking on its repo.  That means
# multiple ebuilds that use the same git repo cannot safely be
# emerged at the same time.  Until we can get that sorted out,
# allow ebuilds that know they'll conflict to declare a unique
# path for storing the local clone.
: ${CROS_WORKON_GIT_SUFFIX:=}

# @ECLASS-VARIABLE: CROS_WORKON_OUTOFTREE_BUILD
# @DESCRIPTION:
# Do not copy the source tree to $S; instead set $S to the
# source tree and store compiled objects and build state
# in $WORKDIR.  The ebuild is responsible for ensuring
# the build output goes to $WORKDIR, e.g. setting
# O=${WORKDIR}/${P}/build/${board} when compiling the kernel.
: ${CROS_WORKON_OUTOFTREE_BUILD:=}

# Join the tree commits to produce a unique identifier
CROS_WORKON_TREE_COMPOSITE=$(IFS="_"; echo "${CROS_WORKON_TREE[*]}")
IUSE="cros_workon_tree_$CROS_WORKON_TREE_COMPOSITE"

inherit git-2 flag-o-matic

# Sanitize all variables, autocomplete where necessary.
# This function possibly modifies all CROS_WORKON_ variables inplace. It also
# provides a global project_count variable which contains the number of
# projects.
array_vars_autocomplete() {
	# NOTE: This one variable has to have all values explicitly filled in.
	project_count=${#CROS_WORKON_PROJECT[@]}

	# No project_count is really bad.
	[ ${project_count} -eq 0 ] && die "Must have at least one CROS_WORKON_PROJECT"
	# For one project, defaults will suffice.
	[ ${project_count} -eq 1 ] && return

	local count var
	for var in "${ARRAY_VARIABLES[@]}"; do
		eval count=\${#${var}\[@\]}
		if [[ ${count} -ne ${project_count} ]] && [[ ${count} -ne 1 ]]; then
			die "${var} has ${count} projects. ${project_count} or one default expected."
		fi
		# Invariably, ${project_count} is at least 2 here. All variables also either
		# have all items or the first serves as default (or isn't needed if
		# empty). By looking at the second item, determine if we need to
		# autocomplete.
		local i
		if [[ ${count} -ne ${project_count} ]]; then
			for (( i = 1; i < project_count; ++i )); do
				eval ${var}\[i\]=\${${var}\[0\]}
			done
		fi
		eval einfo "${var}: \${${var}[@]}"
	done
}

# Calculate path where code should be checked out.
# Result passed through global variable "path" to preserve proper array quoting.
get_paths() {
	local pathbase
	if [[ -n "${CROS_WORKON_SRCROOT}" ]]; then
		pathbase="${CROS_WORKON_SRCROOT}"
	elif [[ -n "${CHROMEOS_ROOT}" ]]; then
		pathbase="${CHROMEOS_ROOT}"
	else
		# HACK: Figure out the missing legacy path for now
		# this only happens in amd64 chroot with sudo emerge.
		pathbase="/home/${SUDO_USER}/trunk"
	fi

	if [[ "${CATEGORY}" == "chromeos-base" ]] ; then
		pathbase+=/src/platform
	else
		pathbase+=/src/third_party
	fi

	path=()
	local pathelement i
	for (( i = 0; i < project_count; ++i )); do
		pathelement="${pathbase}/${CROS_WORKON_LOCALNAME[i]}"
		if [[ -n "${CROS_WORKON_SUBDIR[i]}" ]]; then
			pathelement+="/${CROS_WORKON_SUBDIR[i]}"
		fi
		path+=( "${pathelement}" )
	done
}

local_copy_git() {
	local src="${1}"
	local dst="${2}"
	CLONE_OPTS="--no-hardlinks --shared"
	PATCHFILE="${dst}"/local_changes.patch

	einfo "Using experimental git copy from ${src}"

	# This produces a local clean copy of src at the same branch.
	git clone ${CLONE_OPTS} "${src}" "${dst}" || \
		die "Cannot clone local copy"

	# collect local changes
	git --binary --git-dir="${src}" --work-dir="${src}/.git" diff HEAD > "${PATCHFILE}" || \
		die "Cannot create local changes patch"

	# apply local changes
	# note: wc prints file name after byte count
	if [ "$(wc -c ${PATCHFILE})" != "0 ${PATCHFILE}" ]; then
		git --git-dir="${dst}" --work-dir="${dst}/.git" apply ${PATCHFILE} || \
			die "Cannot apply local changes"
	fi
}

local_copy_cp() {
	local src="${1}"
	local dst="${2}"
	einfo "Copying sources from ${src}"
	local blacklist=( "${CROS_WORKON_SUBDIR_BLACKLIST[@]/#/--exclude=}" )

	local sl
	for sl in "${CROS_WORKON_SUBDIRS_TO_COPY[@]}"; do
		if [[ -d "${src}/${sl}" ]]; then
			mkdir -p "${dst}/${sl}"
			rsync -a "${blacklist[@]}" "${src}/${sl}"/* "${dst}/${sl}" || \
				die "rsync -a ${blacklist[@]} ${src}/${sl}/* ${dst}/${sl}"
		fi
	done
}

symlink_in_place() {
	local src="${1}"
	local dst="${2}"
	einfo "Using experimental inplace build in ${src}."

	SBOX_TMP=":${SANDBOX_WRITE}:"

	if [ "${SBOX_TMP/:$CROS_WORKON_SRCROOT://}" == "${SBOX_TMP}" ]; then
		ewarn "For inplace build you need to modify the sandbox"
		ewarn "Set SANDBOX_WRITE=${CROS_WORKON_SRCROOT} in your env."
	fi

	ln -sf "${src}" "${dst}"
}

local_copy() {
	# Local vars used by all called functions.
	local src="${1}"
	local dst="${2}"

	# If we want to use git, and the source actually is a git repo
	if [ "${CROS_WORKON_INPLACE}" == "1" ]; then
		symlink_in_place "${src}" "${dst}"
	elif [ -n "${CROS_WORKON_LOCALGIT}" ] && [ -d ${srcpath}/.git ]; then
		local_copy_git "${src}" "${dst}"
	elif [ "${CROS_WORKON_OUTOFTREE_BUILD}" == "1" ]; then
		if [ ${project_count} -gt 1 ]; then
			die "Out of Tree Build not compatible with multi-project ebuilds."
		fi
		S="${src}"
	else
		local_copy_cp "${src}" "${dst}"
	fi
}

set_vcsid() {
	export VCSID="${PVR}-${1}"

	if [ "${CROS_WORKON_USE_VCSID}" = "1" ]; then
		append-flags -DVCSID=\\\"${VCSID}\\\"
		MAKEOPTS+=" VCSID=${VCSID}"
	fi
}

cros-workon_src_unpack() {
	local fetch_method # local|git

	# Set the default of CROS_WORKON_DESTDIR. This is done here because S is
	# sometimes overridden in ebuilds and we cannot rely on the global state
	# (and therefore ordering of eclass inherits and local ebuild overrides).
	: ${CROS_WORKON_DESTDIR:=${S}}

	# Fix array variables
	array_vars_autocomplete

	if [[ "${PV}" == "9999" ]]; then
		# Live packages
		fetch_method=local
	else
		fetch_method=git
	fi

	# Hack
	# TODO(msb): remove once we've resolved the include path issue
	# http://groups.google.com/a/chromium.org/group/chromium-os-dev/browse_thread/thread/5e85f28f551eeda/3ae57db97ae327ae
	local p i
	for p in "${CROS_WORKON_LOCALNAME[@]/#/${WORKDIR}/}"; do
		ln -s "${S}" "${p}" &> /dev/null
	done

	local repo=( "${CROS_WORKON_REPO[@]}" )
	local project=( "${CROS_WORKON_PROJECT[@]}" )
	local destdir=( "${CROS_WORKON_DESTDIR[@]}" )
	get_paths

	if [[ "${fetch_method}" == "git" ]] ; then
		all_local() {
			local p
			for p in "${path[@]}"; do
				[[ -d ${p} ]] || return 1
			done
			return 0
		}

		local fetched=0
		if all_local; then
			for (( i = 0; i < project_count; ++i )); do
				# Looks like we already have a local copy of all repositories.
				# Let's use these and checkout ${CROS_WORKON_COMMIT}.
				#  -s: For speed, share objects between ${path} and ${S}.
				#  -n: Don't checkout any files from the repository yet. We'll
				#      checkout the source separately.
				#
				# We don't use git clone to checkout the source because the -b
				# option for clone defaults to HEAD if it can't find the
				# revision you requested. On the other hand, git checkout fails
				# if it can't find the revision you requested, so we use that
				# instead.

				# Destination directory. If we have one project, it's simply
				# ${CROS_WORKON_DESTDIR}. More projects either specify an array or go to
				# ${S}/${project}.

				if [[ "${CROS_WORKON_COMMIT[i]}" == "master" ]]; then
					# Since we don't have a CROS_WORKON_COMMIT revision specified,
					# we don't know what revision the ebuild wants. Let's take the
					# version of the code that the user has checked out.
					#
					# This almost replicates the pre-cros-workon behavior, where
					# the code you had in your source tree was used to build
					# things. One difference here, however, is that only committed
					# changes are included.
					#
					# TODO(davidjames): We should fix the preflight buildbot to
					# specify CROS_WORKON_COMMIT for all ebuilds, and update this
					# code path to fail and explain the problem.
					git clone -s "${path[i]}" "${destdir[i]}" || \
						die "Can't clone ${path[i]}."
						: $(( ++fetched ))
				else
					git clone -sn "${path[i]}" "${destdir[i]}" || \
						die "Can't clone ${path[i]}."
					if ! ( cd ${destdir[i]} && git checkout -q ${CROS_WORKON_COMMIT[i]} ) ; then
						ewarn "Cannot run git checkout ${CROS_WORKON_COMMIT[i]} in ${destdir[i]}."
						ewarn "Is ${path[i]} up to date? Try running repo sync."
						ewarn "Falling back to git.eclass..."
						rm -rf "${destdir[i]}/.git"
					else
						: $(( ++fetched ))
					fi
				fi
			done
			if [[ ${fetched} -gt 0 ]]; then
				# TODO: Id of all repos?
				set_vcsid "$(GIT_DIR="${path[0]}/.git" git rev-parse HEAD)"
				return
			fi
		fi

		for (( i = 0; i < project_count; ++i )); do
			EGIT_REPO_URI="${repo[i]}/${project[i]}.git"
			EGIT_PROJECT="${project[i]}${CROS_WORKON_GIT_SUFFIX}"
			EGIT_SOURCEDIR="${destdir[i]}"
			EGIT_COMMIT="${CROS_WORKON_COMMIT[i]}"
			if [[ "${EGIT_COMMIT}" = "master" ]]; then
				# TODO(davidjames): This code should really error out if
				# ${CROS_WORKON_COMMIT} is master, because it's going to be doing
				# the wrong thing for branches.
				ewarn "=== START HACK ALERT ==="
				ewarn "We don't have a CROS_WORKON_COMMIT for ${project},"
				ewarn "and we can't find what code to use, so we are using"
				ewarn "the latest version. This may break your build or"
				ewarn "produce wrong output. See http://crosbug.com/6506"
				ewarn "=== END HACK ALERT ==="
			fi
			# Clones to /var, copies src tree to the /build/<board>/tmp.
			git-2_src_unpack
			# TODO(zbehan): Support multiple projects for vcsid?
		done
		set_vcsid "${CROS_WORKON_COMMIT[0]}"
		return
	fi

	einfo "Using local source dir(s): ${path[*]}"

	# Clone from the git host + repository path specified by
	# CROS_WORKON_REPO + CROS_WORKON_PROJECT. Checkout source from
	# the branch specified by CROS_WORKON_COMMIT into the workspace path.
	# If the repository exists just punt and let it be copied off for build.
	if [[ "${fetch_method}" == "local" && ! -d ${path} ]] ; then
		ewarn "Sources are missing in ${path}"
		ewarn "You need to cros_workon and repo sync your project. For example if you are working on the flimflam ebuild and repository:"
		ewarn "cros_workon start --board=x86-generic flimflam"
		ewarn "repo sync flimflam"
	fi

	einfo "path: ${path[*]}"
	einfo "destdir: ${destdir[*]}"
	# Copy source tree to /build/<board>/tmp for building
	for (( i = 0; i < project_count; ++i )); do
		local_copy "${path[i]}" "${destdir[i]}" || \
			die "Cannot create a local copy"
		set_vcsid "$(GIT_DIR="${path[0]}/.git" git rev-parse HEAD)"
	done
}

cros-workon_pkg_info() {
	print_quoted_array() { printf '"%s"\n' "$@"; }

	array_vars_autocomplete > /dev/null
	get_paths
	CROS_WORKON_SRCDIR=("${path[@]}")

	local val var
	for var in CROS_WORKON_SRCDIR CROS_WORKON_PROJECT ; do
		eval val=(\"\${${var}\[@\]}\")
		echo ${var}=\($(print_quoted_array "${val[@]}")\)
	done
}

EXPORT_FUNCTIONS src_unpack pkg_info
