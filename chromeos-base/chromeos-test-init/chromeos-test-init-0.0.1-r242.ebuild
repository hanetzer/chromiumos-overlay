# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="04bb97f1a0d1a8750c66cfc38951fa537647ddc7"
CROS_WORKON_TREE="de3a6088eb492a49d58ccac7837935f1c41cc27e"
CROS_WORKON_PROJECT="chromiumos/platform/init"
CROS_WORKON_LOCALNAME="init"

inherit cros-workon

DESCRIPTION="Additional upstart jobs that will be installed on test images"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

src_install() {
	insinto /etc/init
	doins test-init/*.conf
}

