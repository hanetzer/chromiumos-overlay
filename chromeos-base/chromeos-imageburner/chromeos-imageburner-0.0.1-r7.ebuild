# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="4719bdd56057a0928412c9c7b0d8ec43d1d39c76"

KEYWORDS="arm amd64 x86"

inherit cros-debug cros-workon

DESCRIPTION="Image-burning service for Chromium OS."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
 
RDEPEND="chromeos-base/libchromeos
         chromeos-base/libcros
         dev-libs/dbus-glib
         dev-libs/glib"

DEPEND="${RDEPEND}"

CROS_WORKON_PROJECT="image-burner"
CROS_WORKON_LOCALNAME="${CROS_WORKON_PROJECT}"

src_compile() {
	tc-export CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	export CXXFLAGS="${CXXFLAGS} -gstabs"
	emake image_burner || die "chromeos-imageburner compile failed."
	emake image_burner_tester || \
		die "chromeos-imageburner_tester compile failed."
}

src_install() {
	dosbin "${S}/image_burner"
	dosbin "${S}/image_burner_tester"

	insinto /etc/dbus-1/system.d
	doins "${S}/ImageBurner.conf"

	insinto /usr/share/dbus-1/system-services
	doins "${S}/org.chromium.ImageBurner.service"
}
