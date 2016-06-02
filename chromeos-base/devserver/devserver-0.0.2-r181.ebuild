# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="7247f9c647a4bd6d3bf4837faa3e9dc61d713c0a"
CROS_WORKON_TREE="20c2dc369475e75618cd33ac88b6fd9230a1cf83"
CROS_WORKON_PROJECT="chromiumos/platform/dev-util"
CROS_WORKON_LOCALNAME="dev"
CROS_WORKON_OUTOFTREE_BUILD="1"

inherit cros-workon python

DESCRIPTION="Server to cache Chromium OS build artifacts from Google Storage."
HOMEPAGE="http://dev.chromium.org/chromium-os/how-tos-and-troubleshooting/using-the-dev-server"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="!<chromeos-base/cros-devutils-0.0.2
	chromeos-base/devserver-deps"
DEPEND="
	dev-python/psutil
"

src_install() {
	emake install DESTDIR="${D}"

	insinto "$(python_get_sitedir)/update_payload"
	doins $(printf '%s\n' host/lib/update_payload/*.py | grep -v unittest)
	doins host/lib/update_payload/update-payload-key.pub.pem
	dobin host/start_devserver

	# Install Mob* Monitor checkfiles for the devserver.
	insinto "/etc/mobmonitor/checkfiles/devserver/"
	doins -r "${S}/checkfiles/devserver/"*
}
