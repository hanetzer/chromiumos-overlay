# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="600a4881ff45ef7c804e96952451891cf6ed167c"

inherit toolchain-funcs flag-o-matic cros-workon autotest

DESCRIPTION="Autotest hardware Components test"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"

IUSE="+autox +xset +tpmtools opengles hardened"
# Enable autotest by default.
IUSE="${IUSE} +autotest"

RDEPEND=">chromeos-base/autotest-tests-0.0.1-r187"
DEPEND="${RDEPEND}"

IUSE_TESTS="+tests_hardware_Components"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_PROJECT=autotest
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

AUTOTEST_DEPS_LIST=""
AUTOTEST_CONFIG_LIST=""
AUTOTEST_PROFILERS_LIST=""

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"

src_compile() {
	true # Nothing to be compiled here...
}

src_install() {
	are_we_used || return 0
	einfo "Install public approved components list"
	local dir="client/site_tests/hardware_Components"
	insinto "/usr/local/autotest/${dir}"
	doins "${AUTOTEST_WORKDIR}/${dir}/approved_components"
}
