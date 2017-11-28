# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="248eec5d367fdb8adf7e39babbbcb0b21d77ac7d"
CROS_WORKON_TREE="ab75604a11bd1f8a298c2ed04023993ffd8b8b25"
CROS_WORKON_PROJECT="chromiumos/platform/mosys"
CROS_WORKON_LOCALNAME="../platform/mosys"

inherit flag-o-matic toolchain-funcs cros-unibuild cros-workon

DESCRIPTION="Utility for obtaining various bits of low-level system info"
HOMEPAGE="http://mosys.googlecode.com/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="static unibuild"

# We need util-linux for libuuid.
RDEPEND="unibuild? (
		chromeos-base/chromeos-config
		sys-apps/dtc
	)
	sys-apps/util-linux
	>=sys-apps/flashmap-0.3-r4"
DEPEND="${RDEPEND}"

src_configure() {
	# Generate a default .config for our target architecture.
	einfo "using default configuration for $(tc-arch)"
	ARCH=$(tc-arch) emake defconfig
	tc-export AR CC LD PKG_CONFIG
	export LDFLAGS="$(raw-ldflags)"

	if use unibuild; then
		cp "${SYSROOT}${UNIBOARD_DTB_INSTALL_PATH}" \
			lib/cros_config/config.dtb
		echo "CONFIG_CROS_CONFIG=y" >>.config
	fi
}

src_test() {
	if use unibuild; then
		echo "CONFIG_TEST=y" >>.config
		ARCH=$(tc-arch) emake simple_tests

		./simple_tests || die "Tests failed"
	fi
}

src_install() {
	dosbin mosys

	# Install the optional static binary if supported.
	use static && dosbin mosys_s

	dodoc README TODO
}
