# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="6e6645d622da2543c998ed836b2f6f69f2bc2299"

inherit cros-workon autotest

DESCRIPTION="Autotest common deps"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"

# Autotest enabled by default.
IUSE="+autotest"

CROS_WORKON_PROJECT=autotest
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

# following deps don't compile: boottool, mysql, pgpool, pgsql, systemtap, # dejagnu, libcap, libnet
# following deps are not deps: factory
# following tests are going to be moved: chrome_test
AUTOTEST_DEPS_LIST="glbench gtest hdparm ibusclient iotools iwcap libaio realtimecomm_playground sysstat"

AUTOTEST_FORCE_TEST_LIST="myfaketest"

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

# deps/gtest
RDEPEND="
  dev-cpp/gtest
"

# deps/chrome_test
#RDEPEND="${RDEPEND}
#  chromeos-base/chromeos-chrome
#"

# deps/ibusclient
RDEPEND="${RDEPEND}
  app-i18n/ibus
  dev-libs/glib
  sys-apps/dbus
"

# deps/iwcap
RDEPEND="${RDEPEND}
  dev-libs/libnl
"

# deps/glbench
RDEPEND="${RDEPEND}
  dev-cpp/gflags
  chromeos-base/libchrome
  virtual/opengl
  opengles? ( virtual/opengles )
"

DEPEND="${RDEPEND}"

src_prepare() {
	autotest_src_prepare

	pushd "${AUTOTEST_WORKDIR}/client/site_tests/" 1> /dev/null || die
	mkdir myfaketest
	cd myfaketest

	# NOTE: Here we create a fake test case, that does not do anything except for
	# setup of all deps.
cat << ENDL > myfaketest.py
from autotest_lib.client.bin import test, utils

class myfaketest(test.test):
  def setup(self):
ENDL

	for item in ${AUTOTEST_DEPS_LIST}; do
echo "    self.job.setup_dep(['${item}'])" >> myfaketest.py
	done

	chmod a+x myfaketest.py
	popd 1> /dev/null
}

src_install() {
	autotest_src_install

	rm -rf ${D}/usr/local/autotest/client/site_tests/myfaketest || die
}

