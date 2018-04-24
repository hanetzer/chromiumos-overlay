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

# While not all packages utilize USE=test, it's common to write gyp conditionals
# based on the flag.  Add it to the eclass so ebuilds don't have to duplicate it
# everywhere even if they otherwise aren't using the flag.
IUSE="asan cros_host fuzzer test"

REQUIRED_USE="fuzzer? ( asan )"

# Similarly to above, we use gmock/gtest for unittests in platform2 packages.
# Add the dep all the time even if a few packages wouldn't use it as it doesn't
# add any real overhead. As we often use the FRIEND_TEST macro provided by
# gtest/gtest_prod.h in regular class definitions, the gtest dependency is needed
# outside test as well.
DEPEND="
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
"

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

# @FUNCTION: platform_fuzzer_install
# @DESCRIPTION:
# Installs fuzzer targets in one common location for all fuzzing projects.
# @USAGE: <owners file> <fuzzer binary> [--dict dict_file] [--seed_corpus corpus_path] \
#	[--options options_file] [extra files ...]
platform_fuzzer_install() {
	[[ $# -lt 2 ]] && die "usage: ${FUNCNAME} <OWNERS> <program> [options]" \
		"[extra files...]"
	# Don't do anything without USE="fuzzer"
	! use fuzzer && return 0

	local owners=$1
	local prog=$2
	local name="${prog##*/}"
	shift 2

	# Fuzzer option strings.
	local opt_corpus="seed_corpus"
	local opt_dict="dict"
	local opt_option="options"

	(
		# Install fuzzer program.
		exeinto "/usr/libexec/fuzzers"
		doexe "${prog}"
		# Install owners file.
		insinto "/usr/libexec/fuzzers"
		newins "${owners}" "${name}.owners"

		# Install other fuzzer files (dict, seed corpus etc.) if provided.
		[[ $# -eq 0 ]] && return 0
		# Parse the arguments.
		local opts=$(getopt -o '' -l "${opt_corpus}:,${opt_dict}:,${opt_option}:" -- "$@")
		[[ $? -ne 0 ]] && die "platform_fuzzer_install: Incorrect options: $*"
		eval set -- "${opts}"

		while [[ $# -gt 0 ]]; do
			case "$1" in
				"--${opt_corpus}")
					if [[ -f "$2" ]]; then
						# Do a direct install if seed corpus is a file.
						[[ "$2" != *.zip ]] && die "Not a zip file: $2"
						newins "$2" "${name}_seed_corpus.zip"
					elif [[ -d "$2" ]]; then
						# Zip and install the seed corpus directory.
						pushd "$2" >/dev/null || die
						zip -rj - . | newins - "${name}_seed_corpus.zip"
						popd >/dev/null || die
					else
						die "Invalid seed corpus location $2"
					fi
					shift 2 ;;
				"--${opt_dict}")
					newins "$2" "${name}.dict"
					shift 2 ;;
				"--${opt_option}")
					newins "$2" "${name}.options"
					shift 2 ;;
				--)
					shift ;;
				*)
					doins "$1"
					shift ;;
			esac
		done
	)
}

# @FUNCTION: platform_fuzzer_test
# @DESCRIPTION:
# Tests a fuzzer binary (passed as an argument) against a small corpus of
# files. This is needed to make sure the fuzzer is built correctly and runs
# properly before being uploaded for contiguous tests.
platform_fuzzer_test() {
	if use fuzzer; then
		"$@" -runs=0 "${PLATFORM_TOOLDIR}"/fuzzer_corpus || die
	fi
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
	asan-setup-env
	fuzzer-setup-env
	platform_configure "${S}/${PLATFORM_GYP_FILE}" "$@"
}

platform_src_test() {
	# We pass SRC along so unittests can access data files in their checkout.
	# It's also the name used by the common.mk framework.
	export SRC="${S}"

	platform_test "pre_test"
	[[ "${PLATFORM_NATIVE_TEST}" == "yes" ]] && ! platform_is_native &&
		ewarn "Skipping unittests for non-x86: ${PN}" && return 0

	platform_pkg_test
	platform_test "post_test"
}

platform_install_dbus_client_lib() {
	local libname=${1:-${PN}}

	local client_includes=/usr/include/${libname}-client
	local client_test_includes=/usr/include/${libname}-client-test

	# Install DBus proxy headers.
	insinto "${client_includes}/${libname}"
	doins "${OUT}/gen/include/${libname}/dbus-proxies.h"
	insinto "${client_test_includes}/${libname}"
	doins "${OUT}/gen/include/${libname}/dbus-proxy-mocks.h"

	# Install pkg-config for client libraries.
	"${PLATFORM_TOOLDIR}/generate_pc_file.sh" \
		"${OUT}" lib${libname}-client "${client_includes}" ||
		die "Error generating lib${libname}-client.pc file"
	"${PLATFORM_TOOLDIR}/generate_pc_file.sh" \
		"${OUT}" lib${libname}-client-test "${client_test_includes}" ||
		die "Error generating lib${libname}-client-test.pc file"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}/lib${libname}-client.pc"
	doins "${OUT}/lib${libname}-client-test.pc"
}

EXPORT_FUNCTIONS src_compile src_test src_configure src_unpack
