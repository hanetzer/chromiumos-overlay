# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="1bdb7a928e92339e4b97d6f951d4c0488fd183c2"
CROS_WORKON_TREE="2ab8a80af6ce1fdb02ec17401e1b20c6ab89213e"
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
DEPEND=""

src_install() {
	emake install DESTDIR="${D}"
	insinto "$(python_get_sitedir)"
	# Copy the python files in this directory except __init__.py
	doins $(find host/lib/ -name '*.py' | grep -v __init__)

	insinto "$(python_get_sitedir)/update_payload"
	doins $(printf '%s\n' host/lib/update_payload/*.py | grep -v unittest)
	doins host/lib/update_payload/update-payload-key.pub.pem
	dobin host/start_devserver
}
