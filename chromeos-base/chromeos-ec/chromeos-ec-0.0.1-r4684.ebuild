# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

# A note about this ebuild: this ebuild is Unified Build enabled but
# not in the way in which most other ebuilds with Unified Build
# knowledge are: the primary use for this ebuild is for engineer-local
# work or firmware builder work. In both cases, the build might be
# happening on a branch in which only one of many of the models are
# available to build. The logic in this ebuild succeeds so long as one
# of the many models successfully builds.

EAPI="4"

CROS_WORKON_COMMIT=("375ecebcb74efcba906b12219ac73e37d3952799" "f6187c733f349b9529006f6d1afbc42f150c2bf0" "6283eeeaf5ccebcca982d5318b36d49e7b32cb6d")
CROS_WORKON_TREE=("a05b9a6805fa5898b7f41dca138a2395b555b7c5" "c2bff699d1d7a50808c0cefcd56a078f9292db0d" "cc44d33412e29b2c10a03bf8ac819f5630af57b2")
CROS_WORKON_PROJECT=(
	"chromiumos/platform/ec"
	"chromiumos/third_party/tpm2"
	"chromiumos/third_party/cryptoc"
)
CROS_WORKON_LOCALNAME=(
	"ec"
	"../third_party/tpm2"
	"../third_party/cryptoc"
)
CROS_WORKON_DESTDIR=(
	"${S}/platform/ec"
	"${S}/third_party/tpm2"
	"${S}/third_party/cryptoc"
)

inherit toolchain-funcs cros-ec-board cros-workon cros-unibuild coreboot-sdk

DESCRIPTION="Embedded Controller firmware code"
HOMEPAGE="https://www.chromium.org/chromium-os/ec-development"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="quiet verbose coreboot-sdk unibuild"

RDEPEND="dev-embedded/libftdi"
DEPEND="
	${RDEPEND}
	virtual/chromeos-ec-private-files
	virtual/chromeos-ec-touch-firmware
	unibuild? ( chromeos-base/chromeos-config )
"

# We don't want binchecks since we're cross-compiling firmware images using
# non-standard layout.
RESTRICT="binchecks"

src_unpack() {
	cros-workon_src_unpack
	S+="/platform/ec"
}

src_prepare() {
	if ! [[ ${PV} = 9999* ]]; then
		# Link the private sources in the private/ sub-directory if needed
		ln -sf ${SYSROOT}/firmware/ec-private ${S}/private
	fi
}

src_configure() {
	cros-workon_src_configure
}

set_build_env() {
	if ! use coreboot-sdk; then
		export CROSS_COMPILE_arm=arm-none-eabi-
		export CROSS_COMPILE_i386=i686-pc-linux-gnu-
	else
		export CROSS_COMPILE_arm=${COREBOOT_SDK_PREFIX_arm}
		export CROSS_COMPILE_i386=${COREBOOT_SDK_PREFIX_x86_32}
	fi

	# nds32 always uses coreboot-sdk
	export CROSS_COMPILE_nds32=${COREBOOT_SDK_PREFIX_nds32}

	tc-export CC BUILD_CC
	export HOSTCC=${CC}
	export BUILDCC=${BUILD_CC}

	get_ec_boards

	EC_OPTS=()
	use quiet && EC_OPTS+=( -s V=0 )
	use verbose && EC_OPTS+=( V=1 )
}

src_compile() {
	set_build_env

	local target
	einfo "Building targets: ${TARGETS[@]}"
	for target in "${EC_BOARDS[@]}"; do
		# Always pass TOUCHPAD_FW parameter: boards that do not require
		# it will simply ignore the parameter, even if the touchpad FW
		# file does not exist.
		local ec_opts_all=(
			TOUCHPAD_FW="${SYSROOT}/firmware/${target}/touchpad.bin"
		)

		BOARD=${target} emake "${EC_OPTS[@]}" clean
		BOARD=${target} emake "${EC_OPTS[@]}" "${ec_opts_all[@]}" all
		BOARD=${target} emake "${EC_OPTS[@]}" tests
	done
}

#
# Install firmware binaries for a specific board.
#
# param $1 - the board name.
# param $2 - the output directory to install artifacts.
#
board_install() {
	local board="$1"
	local destdir="$2"
	local ecrw

	einfo "Installing EC for ${board} into ${destdir}"
	insinto "${destdir}"
	pushd "build/${board}" >/dev/null || die

	openssl dgst -sha256 -binary RO/ec.RO.flat > RO/ec.RO.hash
	doins ec.bin
	if grep -q '^CONFIG_VBOOT_EFS=y' .config; then
		# This extracts EC_RW.bin (= RW_A region image) from ec.bin.
		futility sign --type rwsig ec.bin || die
		ecrw="EC_RW.bin"
	else
		ecrw="RW/ec.RW.flat"
	fi
	newins "${ecrw}" ec.RW.bin
	openssl dgst -sha256 -binary "${ecrw}" > RW/ec.RW.hash
	doins RW/ec.RW.hash
	# Intermediate file for debugging.
	doins RW/ec.RW.elf

	# Install RW_B files except for RWSIG, which uses the same files as RW_A
	if grep -q '^CONFIG_RW_B=y' .config && \
			! grep -q '^CONFIG_RWSIG_TYPE_RWSIG=y' .config; then
		openssl dgst -sha256 -binary RW/ec.RW_B.flat > RW/ec.RW_B.hash
		newins RW/ec.RW_B.flat ec.RW_B.bin
		doins RW/ec.RW_B.hash
		# Intermediate file for debugging.
		doins RW/ec.RW_B.elf
	fi

	if grep -q '^CONFIG_FW_INCLUDE_RO=y' .config; then
		newins RO/ec.RO.flat ec.RO.bin
		doins RO/ec.RO.hash
		# Intermediate file for debugging.
		doins RO/ec.RO.elf
	fi

	# The shared objects library is not built by default.
	if grep -q '^CONFIG_SHAREDLIB=y' .config; then
		doins libsharedobjs/libsharedobjs.elf
	fi

	# EC test binaries
	nonfatal doins test-*.bin || ewarn "No test binaries found"
	popd > /dev/null
}

src_install() {
	set_build_env

	local target

	einfo "Installing targets: ${TARGETS[@]}"
	for target in "${EC_BOARDS[@]}"; do
		board_install "${target}" "/firmware/${target}"  \
			|| die  "Couldn't install ${target}"
	done
	board_install "${EC_BOARDS[0]}" /firmware || die \
		"Couldn't install main firmware"
}

src_test() {
	set_build_env

	# Verify compilation of all boards
	emake "${EC_OPTS[@]}" buildall
}
