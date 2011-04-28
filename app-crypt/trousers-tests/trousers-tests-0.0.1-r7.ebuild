# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="8e30eed90414de081f0f11560ebc534512e37314"

inherit cros-workon autotest

DESCRIPTION="Trousers TPM tests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"
DEPEND="app-crypt/trousers"
RDEPEND="${DEPEND}"

# Enable autotest by default.
IUSE="${IUSE} +autotest"

IUSE_TESTS="
	+tests_hardware_TPM
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_PROJECT=trousers
CROS_WORKON_LOCALNAME=trousers

# path from root of repo
AUTOTEST_CLIENT_SITE_TESTS=autotest

function src_compile {
	# for Makefile
	export TROUSERS_DIR=${WORKDIR}/${P}
	autotest_src_compile
}
