# Copyright 2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/profiles/base/profile.bashrc,v 1.3 2009/07/21 00:08:05 zmedico Exp $

# Set LANG=C globally because it speeds up build times, and we don't need
# localized messages inside of our builds.
export LANG=C

# Since unittests on the buildbots don't automatically get access to an
# X server, don't let local dev stations get access either.  If a test
# really needs an X server, they should launch their own with Xvfb.
unset DISPLAY

if ! declare -F elog >/dev/null ; then
	elog() {
		einfo "$@"
	}
fi

# Dumping ground for build-time helpers to utilize since SYSROOT/tmp/
# can be nuked at any time.
CROS_BUILD_BOARD_TREE="${SYSROOT}/build"
CROS_BUILD_BOARD_BIN="${CROS_BUILD_BOARD_TREE}/bin"

CROS_ADDONS_TREE="/usr/local/portage/chromiumos/chromeos"

# Are we merging for the board sysroot, or for the cros sdk, or for
# the target hardware?  Returns a string:
#  - cros_host (the sdk)
#  - board_sysroot
#  - target_image
# We can't rely on "use cros_host" as USE gets filtred based on IUSE,
# and not all packages have IUSE=cros_host.
cros_target() {
	if [[ ${CROS_SDK_HOST} == "cros-sdk-host" ]] ; then
		echo "cros_host"
	elif [[ ${ROOT%/} == ${SYSROOT%/} ]] ; then
		echo "board_sysroot"
	else
		echo "target_image"
	fi
}

# Load all additional bashrc files we have for this package.
cros_stack_bashrc() {
	local cfg cfgd

	# Old location.
	cfgd="${CROS_ADDONS_TREE}/config/env"
	for cfg in ${PN} ${PN}-${PV} ${PN}-${PV}-${PR} ; do
		cfg="${cfgd}/${CATEGORY}/${cfg}"
		[[ -f ${cfg} ]] && . "${cfg}"
	done

	# New location.
	cfgd="/mnt/host/source/src/third_party/chromiumos-overlay/${CATEGORY}/${PN}"
	export BASHRC_FILESDIR="${cfgd}/files"
	for cfg in ${PN} ${P} ${PF} ; do
		cfg="${cfgd}/${cfg}.bashrc"
		[[ -f ${cfg} ]] && . "${cfg}"
	done
}
cros_stack_bashrc

# The standard bashrc hooks do not stack.  So take care of that ourselves.
# Now people can declare:
#   cros_pre_pkg_preinst_foo() { ... }
# And we'll automatically execute that in the pre_pkg_preinst func.
#
# Note: profile.bashrc's should avoid hooking phases that differ across
# EAPI's (src_{prepare,configure,compile} for example).  These are fine
# in the per-package bashrc tree (since the specific EAPI is known).
cros_lookup_funcs() {
	declare -f | egrep "^$1 +\(\) +$" | awk '{print $1}'
}
cros_stack_hooks() {
	local phase=$1 func
	local header=true

	for func in $(cros_lookup_funcs "cros_${phase}_[-_[:alnum:]]+") ; do
		if ${header} ; then
			einfo "Running stacked hooks for ${phase}"
			header=false
		fi
		ebegin "   ${func#cros_${phase}_}"
		${func}
		eend $?
	done
}
cros_setup_hooks() {
	# Avoid executing multiple times in a single build.
	[[ ${cros_setup_hooks_run+set} == "set" ]] && return

	local phase
	for phase in {pre,post}_{src_{unpack,prepare,configure,compile,test,install},pkg_{{pre,post}{inst,rm},setup}} ; do
		eval "${phase}() { cros_stack_hooks ${phase} ; }"
	done
	export cros_setup_hooks_run="booya"
}
cros_setup_hooks

# Packages that use python will run a small python script to find the
# pythondir. Unfortunately, they query the host python to find out the
# paths for things, which means they inevitably guess wrong.  Export
# the cached values ourselves and since we know these are going through
# autoconf, we can leverage ${libdir} that econf sets up automatically.
cros_pre_src_unpack_python_multilib_setup() {
	# Avoid executing multiple times in a single build.
	[[ ${am_cv_python_version:+set} == "set" ]] && return

	local py=${PYTHON:-python}
	local py_ver=$(${py} -c 'import sys;sys.stdout.write(sys.version[:3])')

	export am_cv_python_version=${py_ver}
	export am_cv_python_pythondir="\${libdir}/python${py_ver}/site-packages"
	export am_cv_python_pyexecdir=${am_cv_python_pythondir}
}

# Since we're storing the wrappers in a board sysroot, make sure that
# is actually in our PATH.
cros_pre_pkg_setup_sysroot_build_bin_dir() {
	PATH+=":${CROS_BUILD_BOARD_BIN}"
}

# The python-utils-r1.eclass:python_wrapper_setup installs a stub program named
# `python2` when PYTHON_COMPAT only lists python-3 programs.  It's designed to
# catch bad packages that still use `python2` even though we said not to.  We
# normally expect packages installed by Gentoo to use specific versions like
# `python2.7`, so the stub doesn't break things there.  In Chromium OS though,
# our chromite code (by design) uses `python2`.  We don't install a copy via
# the ebuild, so we wouldn't rewrite the she-bang.  Delete the stub since it
# doesn't add a lot of value for us and breaks chromite.
cros_post_pkg_setup_python_eclass_hack() {
	rm -f "${T}/python3.3/bin/python2"
}

# Set ASAN settings so they'll work for unittests. http://crbug.com/367879
# We run at src_unpack time so that the hooks have time to get registered
# and saved in the environment.  Portage has a bug where hooks registered
# in the same phase that fails are not run.  http://bugs.gentoo.org/509024
# We run at the _end_ of src_unpack time so that ebuilds which munge ${S}
# (packages which live in the platform2 repo) can do so before we do work.
cros_post_src_unpack_asan_init() {
	local log_path="${T}/asan_logs/asan"
	mkdir -p "${log_path%/*}"

	local strip_sysroot
	if [[ -n "${PLATFORM_GYP_FILE}" ]]; then
		# platform_test chroots into $SYSROOT before running the unit
		# tests, so we need to strip the $SYSROOT prefix from the
		# 'log_path' option specified in $ASAN_OPTIONS and the
		# 'suppressions' option specified in $LSAN_OPTIONS.
		strip_sysroot="${SYSROOT}"
	fi
	export ASAN_OPTIONS+=" log_path=${log_path#${strip_sysroot}}"

	local lsan_suppression="${S}/lsan_suppressions"
	local lsan_suppression_ebuild="${FILESDIR}/lsan_suppressions"
	export LSAN_OPTIONS+=" print_suppressions=0"
	if [[ -f ${lsan_suppression} ]]; then
		export LSAN_OPTIONS+=" suppressions=${lsan_suppression#${strip_sysroot}}"
	elif [[ -f ${lsan_suppression_ebuild} ]]; then
		export LSAN_OPTIONS+=" suppressions=${lsan_suppression_ebuild}"
	fi

	has asan_death_hook ${EBUILD_DEATH_HOOKS} || EBUILD_DEATH_HOOKS+=" asan_death_hook"
}

# Check for & show ASAN failures when dying.
asan_death_hook() {
	local l

	for l in "${T}"/asan_logs/asan*; do
		[[ ! -e ${l} ]] && return 0
		echo
		eerror "ASAN error detected:"
		eerror "$(<"${l}")"
		echo
	done
	return 1
}

# Check for any ASAN failures that were missed while testing.
cros_post_src_test_asan_check() {
	rmdir "${T}/asan_logs" 2>/dev/null || die "asan error not caught"
	mkdir -p "${T}/asan_logs"
}

# Enables C++ exceptions. We normally disable these by default in
#   chromiumos-overlay/chromeos/config/make.conf.common-target
cros_enable_cxx_exceptions() {
	CXXFLAGS=${CXXFLAGS/ -fno-exceptions/ }
	CXXFLAGS=${CXXFLAGS/ -fno-unwind-tables/ }
	CXXFLAGS=${CXXFLAGS/ -fno-asynchronous-unwind-tables/ }
	CFLAGS=${CFLAGS/ -fno-exceptions/ }
	CFLAGS=${CFLAGS/ -fno-unwind-tables/ }
	CFLAGS=${CFLAGS/ -fno-asynchronous-unwind-tables/ }
	# Set the CXXEXCEPTIONS variable to 1 so packages based on common.mk or
	# platform2 gyp inherit this value by default.
	CXXEXCEPTIONS=1
}

# We still use gcc to build packages even the CC or CXX is set to
# something else.
cros_use_gcc() {
	if [[ $(basename ${CC:-gcc}) != *"gcc"* ]]; then
		export CC=${CHOST}-gcc
		export CXX=${CHOST}-g++
	fi
}

filter_clang_syntax() {
	local var flag flags=()
	for var in CFLAGS CXXFLAGS; do
		for flag in ${!var}; do
			if [[ ${flag} != "-clang-syntax" ]]; then
				flags+=("${flag}")
			fi
		done
		export ${var}="${flags[*]}"
		flags=()
	done
}
