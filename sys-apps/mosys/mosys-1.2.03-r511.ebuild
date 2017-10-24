# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="0cadaa95434c27e1e869522ae58eaa91e13040fa"
CROS_WORKON_TREE="5fb4ca293a8c8cc17d69c9ecff9c99b671eccc6e"
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
	# Generate a default .config for our target architecture. This will
	# likely become more sophisticated as we broaden board support.
	einfo "using default configuration for $(tc-arch)"
	ARCH=$(tc-arch) emake defconfig

	tc-export AR CC LD PKG_CONFIG
	export FMAP_LINKOPT="$(${PKG_CONFIG} --libs-only-l fmap)"
	append-ldflags "$(${PKG_CONFIG} --libs-only-L fmap)"
	export LDFLAGS="$(raw-ldflags)"
	append-flags "$(${PKG_CONFIG} --cflags fmap)"
	export CFLAGS

	if use static; then
		#  We can't use append-ldflags because the build system doesn't
		#  handle LDFLAGS correctly:
		#  http://code.google.com/p/mosys/issues/detail?id=3
		append-flags "-static"
	fi
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
	nonfatal dosbin mosys_s
	dodoc README TODO
}
