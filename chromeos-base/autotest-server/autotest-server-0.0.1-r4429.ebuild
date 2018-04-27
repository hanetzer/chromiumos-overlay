# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="13b26ccb4a1bb4fa0beb383e5a38c1996f31e110"
CROS_WORKON_TREE="deb321adbe71ec157b0c77a6d3f49bb81cac62b0"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest/files

inherit cros-workon cros-constants

DESCRIPTION="Autotest scripts and tools"
HOMEPAGE="http://dev.chromium.org/chromium-os/testing"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/autotest-server-deps
	chromeos-base/autotest-web-frontend
	chromeos-base/infra-virtualenv
	chromeos-base/lucifer
	chromeos-base/tast-cmd
	chromeos-base/tast-remote-tests-cros
"

DEPEND=""

AUTOTEST_WORK="${WORKDIR}/autotest-work"
AUTOTEST_BASE="/autotest"

src_prepare() {
	mkdir -p "${AUTOTEST_WORK}"
	cp -fpru "${S}"/* "${AUTOTEST_WORK}/" &>/dev/null
	find "${AUTOTEST_WORK}" -name '*.pyc' -delete

	rm "${AUTOTEST_WORK}"/shadow_config.ini
	# We want to create a symlink here instead.
	rm -rf "${AUTOTEST_WORK}"/logs
}

src_compile() {
	protoc --proto_path "${S}" --python_out="${AUTOTEST_WORK}" "${S}/tko/tko.proto"
	protoc --proto_path "${S}" --python_out="${AUTOTEST_WORK}" "${S}/site_utils/cloud_console.proto"
}

src_configure() {
	cros-workon_src_configure
}

src_install() {
	insinto "${AUTOTEST_BASE}"
	doins -r "${AUTOTEST_WORK}"/*
	chmod a+x "${D}/${AUTOTEST_BASE}"/tko/*.cgi

	dosym /var/log/autotest "${AUTOTEST_BASE}"/logs

	insinto /etc/init
	doins "${FILESDIR}"/*.conf
}

src_test() {
	# Run the autotest unit tests.
	./utils/unittest_suite.py --debug || die "Autotest unit tests failed."
}
