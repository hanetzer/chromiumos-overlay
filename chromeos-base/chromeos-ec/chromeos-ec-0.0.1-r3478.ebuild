# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI="4"

CROS_WORKON_COMMIT=("46ed8a026f0370de341cb0ebb192ad91a936345b" "81e70877e2e3387beac631dd7acaeed4a7c13022" "7c350b9428c7d478559e25b368d0da66098d2cae")
CROS_WORKON_TREE=("2127120d902ec39a4da950d8fafd4f17bd3290e1" "a2008cb559c09d3cf02fe7fd8463010bc7d289df" "88bde8511d7aa0ecf89a3a2c6b454a272c688054")
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
