# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-workon

DESCRIPTION="Chrome OS ACPI Scripts"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""

RDEPEND="sys-power/acpid"

CROS_WORKON_LOCALNAME="acpi"
CROS_WORKON_PROJECT="acpi"

src_install() {
  dodir /etc/acpi/events
  dodir /etc/acpi

  install -m 0755 -o root -g root "${S}"/event_* "${D}"/etc/acpi/events
  install -m 0755 -o root -g root "${S}"/action_* "${D}"/etc/acpi
}
