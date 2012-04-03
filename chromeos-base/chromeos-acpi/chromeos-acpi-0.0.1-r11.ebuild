# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="29a0ac50e0758ea5f5c1392654059006ddab5a59"
CROS_WORKON_TREE="b76c085abdb644dc94dacee25798d002f8b34772"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/acpi"

inherit cros-workon

DESCRIPTION="Chrome OS ACPI Scripts"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""

RDEPEND="sys-power/acpid
         chromeos-base/chromeos-init"

CROS_WORKON_LOCALNAME="acpi"

src_install() {
  dodir /etc/acpi/events
  dodir /etc/acpi

  install -m 0755 -o root -g root "${S}"/event_* "${D}"/etc/acpi/events
  install -m 0755 -o root -g root "${S}"/action_* "${D}"/etc/acpi

  dodir /etc/init
  install --owner=root --group=root --mode=0644 "${S}"/acpid.conf \
                                                "${D}/etc/init/"

}
