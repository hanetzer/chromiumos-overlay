# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit autotest-deponly

# The autotest-dep package name.
PACKAGE="uiautomator"

DESCRIPTION="Ebuild that installs cheets autotest-dep package into dep directory"
HOMEPAGE="https://github.com/xiaocong/uiautomator"
GIT_HASH="0e927d06f855d78d58e26fcff8119258e97fb276"
SRC_URI="https://github.com/xiaocong/uiautomator/archive/${GIT_HASH}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

# Autotest enabled by default.
IUSE="+autotest"

AUTOTEST_DEPS_LIST="${PACKAGE}"
AUTOTEST_CONFIG_LIST=
AUTOTEST_PROFILERS_LIST=

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

S=${WORKDIR}

src_unpack() {
	default
	cd "${WORKDIR}"/${PN}-*
	S=${PWD}
}

src_prepare() {
	autotest-deponly_src_prepare
}

src_compile() {
	# Unlike all other autotest-dep projects which are under autotest repo, this
	# ebuild needs to manully create autotest package-like environment during
	# emerge stage. In addition, all autotest package requires basic fake test
	# during compile stage, so we also need to create ${PACKAGE}.py to workdir
	# and create autotest_workdir manually.
	cp "${FILESDIR}/setup.py" "${WORKDIR}/${PACKAGE}.py" || die
	if [[ ! -e "${AUTOTEST_WORKDIR}/client/deps/${PACKAGE}" ]]; then
		mkdir -p "${AUTOTEST_WORKDIR}/client/deps"
		ln -s "${WORKDIR}" "${AUTOTEST_WORKDIR}/client/deps/${PACKAGE}" || die
	fi
	autotest_src_compile
	if [[ -e "${ROOT}/${AUTOTEST_BASE}/client/deps/${PACKAGE}/.version" ]]; then
		cp "${ROOT}/${AUTOTEST_BASE}/client/deps/${PACKAGE}/.version" "${WORKDIR}/" || die
	fi
	# Clean up autotest workdir which we don't need in final package.
	rm -rf "${AUTOTEST_WORKDIR}"
}

src_install() {
	insinto "${AUTOTEST_BASE}"/client/deps/${PACKAGE}
	doins -r .
	dosym "${PACKAGE}-${GIT_HASH}/${PACKAGE}" "${AUTOTEST_BASE}/client/deps/${PACKAGE}/${PACKAGE}"
}
