# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="b2bc97f7c89b0ca5f90aebfb57bc072922b95472"
CROS_WORKON_TREE="d6ab9ed82e0a5b5e15512bf6e16202bdccb39697"
CROS_WORKON_PROJECT="chromiumos/platform/vpd"

inherit cros-workon

DESCRIPTION="ChromeOS vital product data utilities"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="static"

# util-linux is for libuuid.
DEPEND="sys-apps/util-linux"
# shflags for dump_vpd_log.
# chromeos-activate-date for ActivateDate upstart and script.
RDEPEND="
	sys-apps/flashrom
	dev-util/shflags
	virtual/chromeos-activate-date
	"

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	tc-export CC
	use static && append-ldflags -static
	emake all
}

src_install() {
	# This target list should be architecture specific
	# (no ACPI stuff on ARM for instance)
	dosbin vpd vpd_s util/dump_vpd_log util/block_devmode_vpd

	# install the init script
	insinto /etc/init
	doins init/vpd-log.conf
}

# disabled due to buildbot failure
#src_test() {
#	emake test || die "test failed."
#}
