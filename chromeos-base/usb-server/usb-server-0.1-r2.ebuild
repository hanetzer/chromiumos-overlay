# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can
# be found in the LICENSE file.

EAPI="2"

DESCRIPTION="Install stubs for USB server from www.incentivespro.com"

# This package is all BSD, but it contains a locally-written installer
# script that downloads and installs a free-as-in-beer EULA'd package
# from www.incentivespro.com.  This is only run by the end-user (and
# only for test systems); we do not distribute it as part of CrOS.
# The license for the software that is downloaded is in
# files/LICENSE.incentivespro

LICENSE="BSD"
SLOT="0"
KEYWORDS="x86"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

src_install() {
  dobin "${FILESDIR}"/install-usbsrv
  dobin "${FILESDIR}"/usbsrv
}
