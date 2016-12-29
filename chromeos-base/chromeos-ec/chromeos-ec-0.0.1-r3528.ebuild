# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI="4"

CROS_WORKON_COMMIT=("6731584e15a60af73721d1500c2e5f6d7f6fcc3b" "569c3c58dc69d5c8628f3c329937c136be38df3f" "6283eeeaf5ccebcca982d5318b36d49e7b32cb6d")
CROS_WORKON_TREE=("4d7f044a612a83a0020205c1ad4e45bce5b9b368" "93226a82bcfe5b7049d981c0546add74e51de5b3" "cc44d33412e29b2c10a03bf8ac819f5630af57b2")
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
}

src_compile() {
	set_build_env

	local board
	for board in "${EC_BOARDS[@]}"; do
		BOARD=${board} emake clean
		BOARD=${board} emake all
		BOARD=${board} emake tests
	done
}

#
# Install firmware binaries for a specific board.
#
# param $1 - the board name.
# param $2 - the output directory to install artifacts.
#
board_install() {
	insinto $2
	pushd build/$1 >/dev/null || die

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

	# The first board should be the main EC
	local ec="${EC_BOARDS[0]}"

	# EC firmware binaries
	board_install ${ec} /firmware

	# Install additional firmwares
	local board
	for board in "${EC_BOARDS[@]}"; do
		board_install ${board} /firmware/${board}
	done
}

src_test() {
	# Verify compilation of all boards
	emake buildall
}
