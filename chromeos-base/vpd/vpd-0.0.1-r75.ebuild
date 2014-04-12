# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="fe84138c901532302177d028436992ba36d5fa94"
CROS_WORKON_TREE="757279bde9e8a686bf6c2c8d21aca4c55e139747"
CROS_WORKON_PROJECT="chromiumos/platform/vpd"

inherit cros-workon

DESCRIPTION="ChromeOS vital product data utilities"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

# util-linux is for libuuid.
DEPEND="sys-apps/util-linux"
# shflags for dump_vpd_log.
# chromeos-activate-date for ActivateDate upstart and script.
RDEPEND="
	!<chromeos-base/chromeos-init-0.0.19
	sys-apps/flashrom
	dev-util/shflags
	virtual/chromeos-activate-date
	"

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	tc-export CC
	emake all
}

src_install() {
	# This target list should be architecture specific
	# (no ACPI stuff on ARM for instance)
	dosbin vpd vpd_s util/dump_vpd_log

	# install the init script
	insinto /etc/init
	doins init/vpd-log.conf
}

# disabled due to buildbot failure
#src_test() {
#	emake test || die "test failed."
#}
