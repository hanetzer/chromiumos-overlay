# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: platform.eclass
# @MAINTAINER:
# ChromiumOS Build Team
# @BUGREPORTS:
# Please report bugs via http://crbug.com/new (with label Build)
# @VCSURL: https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay/+/master/eclass/@ECLASS@
# @BLURB: helper eclass for building Chromium package in src/platform2
# @DESCRIPTION:
# Packages in src/platform2 are in active development. We want builds to be
# incremental and fast. This centralized the logic needed for this.

# @ECLASS-VARIABLE: WANT_LIBCHROME
# @DESCRIPTION:
# Set to yes if the package needs libchrome.
: ${WANT_LIBCHROME:="yes"}

# @ECLASS-VARIABLE: PLATFORM_SUBDIR
# @DESCRIPTION:
# Subdir in src/platform2 where the gyp file is located.

# @ECLASS-VARIABLE: PLATFORM_NATIVE_TEST
# @DESCRIPTION:
# If set to yes, run the test only for amd64 and x86.
: ${PLATFORM_NATIVE_TEST:="no"}

# @ECLASS-VARIABLE: PLATFORM_GYP_FILE
# @DESCRIPTION:
# Name of GYP file within PLATFORM_SUBDIR.
: ${PLATFORM_GYP_FILE:="${PLATFORM_SUBDIR}.gyp"}

inherit cros-debug cros-workon flag-o-matic toolchain-funcs multiprocessing

[[ "${WANT_LIBCHROME}" == "yes" ]] && inherit libchrome

IUSE="asan clang cros_host"
REQUIRED_USE="asan? ( clang )"

platform() {
	local platform2_py="${PLATFORM_TOOLDIR}/platform2.py"
	local action="$1"
	shift

	local cmd=(
		"${platform2_py}"
		$(platform_get_target_args)
		--libdir="/usr/$(get_libdir)"
		--use_flags="${USE}"
		--jobs=$(makeopts_jobs)
		--action="${action}"
		--cache_dir="$(cros-workon_get_build_dir)"
		"$@"
	)
	if [[ "${CROS_WORKON_INCREMENTAL_BUILD}" != "1" ]]; then
		cmd+=( --disable_incremental )
	fi
	echo "${cmd[@]}"
	"${cmd[@]}" || die
}

platform_get_target_args() {
	if use cros_host; then
		echo "--host"
	else
		# Avoid --board as we have all the vars we need in the env.
		:
	fi
}

platform_is_native() {
	use amd64 || use x86
}

platform_src_unpack() {
	cros-workon_src_unpack
	if [[ ${#CROS_WORKON_DESTDIR[@]} -gt 1 || "${CROS_WORKON_OUTOFTREE_BUILD}" != "1" ]]; then
		S+="/platform2"
	fi
	PLATFORM_TOOLDIR="${S}/common-mk"
	S+="/${PLATFORM_SUBDIR}"
	export OUT="$(cros-workon_get_build_dir)/out/Default"
}

platform_test() {
	local platform2_test_py="${PLATFORM_TOOLDIR}/platform2_test.py"

	local action="$1"
	local bin="$2"
	local run_as_root="$3"
	local native_gtest_filter="$4"
	local qemu_gtest_filter="$5"

	local run_as_root_flag=""
	if [[ "${run_as_root}" == "1" ]]; then
		run_as_root_flag="--run_as_root"
	fi

	local gtest_filter
	platform_is_native \
		&& gtest_filter=${native_gtest_filter} \
		|| gtest_filter=${qemu_gtest_filter:-${native_gtest_filter}}

	local cmd=(
		"${platform2_test_py}"
		--action="${action}"
		$(platform_get_target_args)
		--sysroot="${SYSROOT}"
		${run_as_root_flag}
	)

	# Only add these options if they're specified ... leads to cleaner output
	# for developers to read.
	[[ -n ${gtest_filter} ]] && cmd+=( --gtest_filter="${gtest_filter}" )
	[[ -n ${P2_TEST_FILTER} ]] && cmd+=( --user_gtest_filter="${P2_TEST_FILTER}" )

	cmd+=(
		--
		"${bin}"
	)
	[[ -n "${P2_VMODULE}" ]] && cmd+=( --vmodule="${P2_VMODULE}" )
	echo "${cmd[@]}"
	"${cmd[@]}" || die
}

platform_src_compile() {
	platform "compile" "all"
}

platform_configure() {
	cros-workon_check_clang_syntax
	platform "configure" "$@"
}

platform_src_configure() {
	cros-debug-add-NDEBUG
	append-lfs-flags
	clang-setup-env
	platform_configure "${S}/${PLATFORM_GYP_FILE}"
}

platform_src_test() {
	platform_test "pre_test"
	[[ "${PLATFORM_NATIVE_TEST}" == "yes" ]] && ! platform_is_native &&
		ewarn "Skipping unittests for non-x86: ${PN}" && return 0

	platform_pkg_test
	platform_test "post_test"
}

EXPORT_FUNCTIONS src_compile src_test src_configure src_unpack
