# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="b6886bc5223e4a365bda75f6f4958a5568aa0484"
CROS_WORKON_TREE="5624d82c63f8e0d4b9a28ab01b5ddd55f98a8dae"
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
