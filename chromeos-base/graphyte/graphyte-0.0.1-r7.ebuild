# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="99a1183a4f4f9a85f17295d8043e7c147c8fe869"
CROS_WORKON_TREE="a459b9efcb112962f986c42c77719e73c4816384"
CROS_WORKON_PROJECT="chromiumos/graphyte"
CROS_WORKON_LOCALNAME="graphyte"
PYTHON_COMPAT=( python2_7 )

inherit cros-workon distutils-r1

DESCRIPTION="Graphyte RF testing framework"
HOMEPAGE="https://sites.google.com/a/google.com/graphyte/home"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND=""
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
