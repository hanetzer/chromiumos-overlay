# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# @ECLASS: gn-chromium.eclass
# @MAINTAINER:
# The Chromium OS Authors. <chromium-os-dev@chromium.org>
# @BLURB: Support generating ninja build files with GN
# @DESCRIPTION:
# Supports using GN (https://code.google.com/p/chromium/wiki/gn), a meta-build
# system that generates Ninja files, in CrOS. Handles injecting toolchain
# and build args expressed in the standard CrOS ways into the Chromium GN build.

inherit cros-debug toolchain-funcs

IUSE="asan clang neon hardfp"
REQUIRED_USE="asan? ( clang )"

# @FUNCTION: _usetf
# @INTERNAL
# @USAGE: <use flag to test>
_usetf()  { usex $1 true false ; }

# @FUNCTION: _gn-chromium_friendly_arch
# @INTERNAL
# @USAGE: <arch>
# @DESCRIPTION:
# Returns the value of 'cpu_arch' argument that is passed to chromium GN.
_gn-chromium_friendly_arch() {
	local arch=${1:-${ARCH}}
	case "${arch}" in
	amd64)
		arch=x64
		;;
	mips)
		local mips_arch mips_endian

		[[ "$(tc-endian)" == big ]] && mips_endian=eb || mips_endian=el
		mips_arch="$($(tc-getCPP) ${CFLAGS} ${CPPFLAGS} -E -P - <<<_MIPS_ARCH)"
		# Strip away any enclosing quotes.
		mips_arch="${mips_arch//\"}"
		case "${mips_arch}" in
		mips64*)
			arch="mips64${mips_endian}"
			;;
		*)
			arch="mips${mips_endian}"
			;;
		esac
		;;
	esac
	echo "${arch}"
}

# @FUNCTION: gn-chromium_get_build_dir
# @USAGE:
# @DESCRIPTION:
# Returns absolute path to the GN build output directory.
gn-chromium_get_build_dir() {
	# For now, just use WORKDIR. In the future, we can add
	# incremental builds like in cros-workon.eclass.
	echo "${WORKDIR}"
}

# @FUNCTION: _gn-chromium_ensure_build_dir
# @INTERNAL
# @USAGE:
# @DESCRIPTION:
# Ensures existence of the directory returned by $(gn-chromium_get_build_dir)
_gn-chromium_ensure_build_dir() {
	mkdir -p "$(gn-chromium_get_build_dir)"
}

# @FUNCTION: gn-chromium_pkg_setup
# @USAGE:
# @DESCRIPTION:
# Checks that the environment is as expected.
gn-chromium_pkg_setup() {
	# Verify that GN is available in the SDK
	gn --version > /dev/null || die "GN not available in SDK!"
}

# @FUNCTION: _gn-chromium_get_args_file
# @INTERNAL
# @USAGE:
# @DESCRIPTION:
# Returns the absolute path of the file used to store arguments for a GN build.
_gn-chromium_get_args_file() {
	echo "$(gn-chromium_get_build_dir)/args.gn"
}

# @FUNCTION: _gn-chromium_print_arm_args
# @INTERNAL
# @USAGE:
# @DESCRIPTION:
# Prints arm-appropriate build configuration arguments, including
#  - arm version (6 or 7),
#  - whether to use neon,
#  - what floating point ABI to use (hard or softfp), and
#  - the appropriate mtune setting.
_gn-chromium_print_arm_args() {
	use arm || die "_gn-chromium_print_arm_args only makes sense on ARM."

	cat <<EOF
arm_version=$([[ ${CHOST} == armv7* ]] && echo "7" || echo "6")
arm_use_neon=$(_usetf neon)
arm_float_abi="$(usex hardfp hard softfp)"
arm_tune="$(get-flag mtune)"
EOF
}

# @FUNCTION: _gn-chromium_print_standard_args
# @INTERNAL
# @USAGE:
# @DESCRIPTION:
# Prints all arguments required to properly run a GN build of Chromium code.
_gn-chromium_print_standard_args() {
	tc-export CC CXX AR PKG_CONFIG
	cat <<EOF
os="chromeos"
pkg_config="${PKG_CONFIG}"
cros_use_custom_toolchain=true
cros_target_cc="${CC}"
cros_target_cxx="${CXX}"
cros_target_ar="${AR}"
cpu_arch="$(_gn-chromium_friendly_arch ${ARCH})"
is_clang=$(_usetf clang)
is_asan=$(_usetf asan)
EOF
	use arm && _gn-chromium_print_arm_args
}

# @FUNCTION: gn-chromium_set_args
# @USAGE: [<arg1=value1> ...]
# @DESCRIPTION:
# Clobbers any existing GN args file with the standard args for this architecture
# plus those passed in, if any.
gn-chromium_set_args() {
	_gn-chromium_ensure_build_dir
	local args_file=$(_gn-chromium_get_args_file)

	echo "$(_gn-chromium_print_standard_args)" > "${args_file}"
	printf '%s\n' "$@" >> "${args_file}"
}

# @FUNCTION: gn-chromium_src_configure
# @USAGE:
# @DESCRIPTION:
# Pulls build configuration (toolchain, compiler/linker flags) into GN
# environment and generates ninja build files into directory returned by
# $(gn-chromium_get_build_dir)
gn-chromium_src_configure() {
	clang-setup-env
	cros-debug-add-NDEBUG
	_gn-chromium_ensure_build_dir
	[[ -e "$(_gn-chromium_get_args_file)" ]] || gn-chromium_set_args
	gn gen "$(gn-chromium_get_build_dir)" --root="${S}"
}

EXPORT_FUNCTIONS pkg_setup src_configure
