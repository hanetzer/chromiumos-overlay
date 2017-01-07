# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=4
CROS_WORKON_COMMIT="bf1f4c514711b3b33f82006f8937c61039a07c71"
CROS_WORKON_TREE="0c1a6e0c65ef286b5edac6a7477617069e61791f"
CROS_WORKON_PROJECT="chromiumos/third_party/adhd"
CROS_WORKON_LOCALNAME="adhd"
CROS_WORKON_USE_VCSID=1

inherit toolchain-funcs autotools cros-workon cros-board systemd user

DESCRIPTION="Google A/V Daemon"
HOMEPAGE="http://www.chromium.org"
SRC_URI=""
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="systemd"

RDEPEND=">=media-libs/alsa-lib-1.0.27
	media-sound/alsa-utils
	media-plugins/alsa-plugins
	media-libs/sbc
	media-libs/speex
	dev-libs/iniparser
	>=sys-apps/dbus-1.4.12
	dev-libs/libpthread-stubs
	virtual/udev"
DEPEND="${RDEPEND}
	media-libs/ladspa-sdk"

# Exclude adhd from clang build. clang rejects access to cp10/cp11,
# which is not correct. Upstream bug here -
# https://llvm.org/bugs/show_bug.cgi?id=23998
src_prepare() {
	cros_use_gcc
	filter_clang_syntax
	cd cras
	eautoreconf
}

src_configure() {
	cd cras
	cros-workon_src_configure
}

src_compile() {
	local board=$(get_current_board_with_variant)
	emake BOARD=${board} CC="$(tc-getCC)" || die "Unable to build ADHD"
}

src_test() {
	if ! use x86 && ! use amd64 ; then
		elog "Skipping unit tests on non-x86 platform"
	else
		cd cras
		emake check
	fi
}

src_install() {
	local board=$(get_current_board_with_variant)
	# Freon boards have "-freon" or "_freon" in their full names.
	# Remove that substring to get the name without freon. E.g.
	# get daisy_spring from daisy_spring-freon,
	# get daisy from daisy_freon,
	# get arm-generic from arm-generic_freon
	local board_no_freon=$(echo $board | sed 's/[-_]freon//g')
	# Get board name without variant E.g.
	# get daisy from daisy_spring,
	# get daisy from daisy_spring-freon
	# get arm-generic from arm-generic_freon
	local board_no_variant=$(get_current_board_no_variant)
	# Search the boards that are relevant to this board. E.g.
	# for daisy_spring-freon, search in this order:
	# daisy_spring-freon, daisy_spring, daisy to find the files.
	local board_all=( ${board} ${board_no_freon} ${board_no_variant} )
	emake BOARD=${board} DESTDIR="${D}" SYSTEMD=$(usex systemd) install

	# install alsa config files
	insinto /etc/modprobe.d
	local b
	for b in "${board_all[@]}" ; do
		local alsa_conf=alsa-module-config/alsa-${b}.conf
		if [[ -f ${alsa_conf} ]] ; then
			doins ${alsa_conf}
			break
		fi
	done

	# install alsa patch files
	insinto /lib/firmware
	for b in "${board_all[@]}" ; do
		local alsa_patch=alsa-module-config/${b}_alsa.fw
		if [[ -f ${alsa_patch} ]] ; then
			doins ${alsa_patch}
			break
		fi
	done

	# install ucm config files
	insinto /usr/share/alsa/ucm
	local board_dir
	for board_dir in "${board_all[@]}" ; do
		if [[ -d ucm-config/${board_dir} ]] ; then
			doins -r ucm-config/${board_dir}/*
			break
		fi
	done
	# install common ucm config files.
	doins -r ucm-config/for_all_boards/*

	# install cras config files
	insinto /etc/cras
	for board_dir in "${board_all[@]}" ; do
		if [[ -d cras-config/${board_dir} ]] ; then
			doins -r cras-config/${board_dir}/*
			break
		fi
	done
	# install common cras config files.
	doins -r cras-config/for_all_boards/*

	# install dbus config allowing cras access
	insinto /etc/dbus-1/system.d
	doins dbus-config/org.chromium.cras.conf
}

pkg_preinst() {
	enewuser "cras"
	enewgroup "cras"
}
