# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI="4"

CROS_WORKON_COMMIT=("2b2478ec6bea2b0117c9ae9c2e610c12e16b5a2d" "1a68fe6fa860f563e8b45e3826110ceec75d61a8" "6283eeeaf5ccebcca982d5318b36d49e7b32cb6d")
CROS_WORKON_TREE=("b87c385604f5c2962d2de0e3ee1b25cc0d68010c" "cc631df6ced2c4451324b52e4e12039b5dbcbf38" "cc44d33412e29b2c10a03bf8ac819f5630af57b2")
S="${WORKDIR}/platform/ec"

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
	"${S}"
	"${WORKDIR}/third_party/tpm2"
	"${WORKDIR}/third_party/cryptoc"
)

inherit toolchain-funcs cros-ec-board cros-workon

DESCRIPTION="Embedded Controller firmware code"
HOMEPAGE="https://www.chromium.org/chromium-os/ec-development"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="quiet verbose"

RDEPEND="dev-embedded/libftdi"
DEPEND="${RDEPEND}"

# We don't want binchecks since we're cross-compiling firmware images using
# non-standard layout.
RESTRICT="binchecks"

src_configure() {
	cros-workon_src_configure
}

set_build_env() {
	# The firmware is running on ARMv7-m (Cortex-M4)
	export CROSS_COMPILE=arm-none-eabi-
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

	local board
	for board in "${EC_BOARDS[@]}"; do
		BOARD=${board} emake "${EC_OPTS[@]}" clean
		BOARD=${board} emake "${EC_OPTS[@]}" all
		BOARD=${board} emake "${EC_OPTS[@]}" tests
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

	einfo "Installing EC for ${board} into ${destdir}"
	insinto "${destdir}"
	pushd "build/${board}" >/dev/null || die

	openssl dgst -sha256 -binary RO/ec.RO.flat > RO/ec.RO.hash
	openssl dgst -sha256 -binary RW/ec.RW.flat > RW/ec.RW.hash

	doins ec.bin
	newins RW/ec.RW.flat ec.RW.bin
	doins RW/ec.RW.hash
	# Intermediate file for debugging.
	doins RW/ec.RW.elf

	if grep -q '^CONFIG_RW_B=y' .config; then
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

	# The first board should be the main EC. With unified builds we have
	# no such thing.
	if ! use unibuild; then
		local ec="${EC_BOARDS[0]}"

		# EC firmware binaries
		board_install ${ec} /firmware
	fi

	# Install additional firmwares
	local board
	for board in "${EC_BOARDS[@]}"; do
		board_install ${board} /firmware/${board}
	done
}

src_test() {
	set_build_env

	# Verify compilation of all boards
	emake "${EC_OPTS[@]}" buildall
}
