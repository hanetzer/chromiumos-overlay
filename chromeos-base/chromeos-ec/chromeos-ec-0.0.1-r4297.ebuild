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

CROS_WORKON_COMMIT=("18f4a483f073b3a8f64f1da2e1089f658e1dbba6" "0f114d2d7eb1950faab02fe479864da5e5d50414" "6283eeeaf5ccebcca982d5318b36d49e7b32cb6d")
CROS_WORKON_TREE=("c7f3fe16da223262a1fde63bc0034f013adbd0ed" "f4b9ff8cddc95379473e742cd947ffbe5f7fa912" "cc44d33412e29b2c10a03bf8ac819f5630af57b2")
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

inherit toolchain-funcs cros-ec-board cros-workon cros-unibuild

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
	virtual/chromeos-ec-touch-firmware
	unibuild? ( chromeos-base/chromeos-config )
"

# We don't want binchecks since we're cross-compiling firmware images using
# non-standard layout.
RESTRICT="binchecks"

src_configure() {
	cros-workon_src_configure
}

set_build_env() {
	if ! use coreboot-sdk; then
		export CROSS_COMPILE_arm=arm-none-eabi-
		export CROSS_COMPILE_i386=i686-pc-linux-gnu-
		export CROSS_COMPILE_nds=nds32le-cros-elf-
	else
		export CROSS_COMPILE_arm=/opt/coreboot-sdk/bin/arm-eabi-
		export CROSS_COMPILE_i386=/opt/coreboot-sdk/bin/i386-elf-
		export CROSS_COMPILE_nds=/opt/coreboot-sdk/bin/nds32le-elf-
	fi
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
	local some_board_built=false
	for board in "${EC_BOARDS[@]}"; do
		# Always pass TOUCHPAD_FW parameter: boards that do not require
		# it will simply ignore the parameter, even if the touchpad FW
		# file does not exist.
		local ec_opts_all=(
			TOUCHPAD_FW="${SYSROOT}/firmware/${board}/touchpad.bin"
		)

		# We need to test whether the board make target
		# exists. For Unified Build EC_BOARDS, the engineer or
		# the firmware builder might be checked out on a
		# firmware branch where only one of the many models in
		# a family are actually available to build at the
		# moment. make fails with exit code 2 when the target
		# doesn't resolve due to error. For non-unibuilds, all
		# EC_BOARDS targets should exist and build.
		BOARD=${board} make -q "${EC_OPTS[@]}" clean

		if [[ $? -ne 2 ]]; then
			some_board_built=true
			BOARD=${board} emake "${EC_OPTS[@]}" clean
			BOARD=${board} emake \
				"${EC_OPTS[@]}" "${ec_opts_all[@]}" all
			BOARD=${board} emake "${EC_OPTS[@]}" tests
		fi
	done

	if [[ ${some_board_built} == false ]]; then
		die "We were not able to find a board target to build from the \
set '${EC_BOARDS[*]}'"
	fi
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
	pushd "build/${board}" >/dev/null || return 1

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
	local board
	local some_board_installed=false

	# Install built firmwares in board-specific directories.
	for board in "${EC_BOARDS[@]}"; do
		board_install "${board}" "/firmware/${board}"

		if [[ $? -eq 0 ]]; then
			some_board_installed=true
		fi
	done

	if [[ ${some_board_installed} == false ]]; then
		die "We were not able to install at least one board from the \
set '${EC_BOARDS[*]}'"
	fi

	if ! use unibuild; then
		# The first board should be the main EC. Install this
		# as the main EC firmware binary.
		board_install "${EC_BOARDS[0]}" /firmware || die \
			"Couldn't install main firmware"
	else
		# Walk through all models and additionally install
		# their build target if not already installed above.
		local model
		local ec

		for model in $(get_model_list); do
			if [[ ! -d "/firmware/${model}" ]]; then
				ec=$(
					get_model_conf_value "${model}" \
					/firmware/build-targets ec
				)

				# This is just nice-to-have so we don't fail
				# if this doesn't install.
				board_install "${ec}" "/firmware/${model}"
			fi
		done
	fi
}

src_test() {
	set_build_env

	# Verify compilation of all boards
	emake "${EC_OPTS[@]}" buildall
}
