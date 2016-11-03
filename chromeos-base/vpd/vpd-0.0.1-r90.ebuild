# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="dba27618ff1ee9027cf20718c9c2733f8b9a4c16"
CROS_WORKON_TREE="dcdbc5787a46144293c6cec2c753dc58eb83ac6d"
CROS_WORKON_PROJECT="chromiumos/platform/vpd"

inherit cros-workon systemd

DESCRIPTION="ChromeOS vital product data utilities"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="static systemd"

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
	dosbin vpd vpd_s util/dump_vpd_log util/set_binary_flag_vpd

	# install the init script
	if use systemd; then
		systemd_dounit init/vpd-log.service
		systemd_enable_service boot-services.target vpd-log.service
	else
		insinto /etc/init
		doins init/vpd-log.conf
	fi
}

# disabled due to buildbot failure
#src_test() {
#	emake test || die "test failed."
#}
