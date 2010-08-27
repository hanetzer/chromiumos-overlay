# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-workon autotest

DESCRIPTION="Autotest common deps"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"

IUSE_TESTS="+tests_myfaketest"

# Autotest enabled by default.
IUSE="+autotest ${IUSE_TESTS}"

CROS_WORKON_PROJECT=autotest
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

# following deps don't compile: boottool, mysql, pgpool, pgsql, systemtap, # dejagnu, libcap, libnet
# following deps are not deps: factory
AUTOTEST_DEPS_LIST="chrome_test glbench gtest hdparm ibusclient iotools iwcap libaio realtimecomm_playground sysstat"

src_prepare() {
	autotest_src_prepare

	pushd "${AUTOTEST_WORKDIR}/client/site_tests/" 1> /dev/null
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
	echo "${item}"
echo "    self.job.setup_dep(['${item}'])" >> myfaketest.py
	done

	chmod a+x myfaketest.py
	popd 1> /dev/null
}

src_install() {
	autotest_src_install

	rm -rf ${D}/client/site_tests/myfaketest
}

