# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Autotest Server Codebase Dependencies. Thse packages are required
to run the web frontend, database and other tools supplied by the Autotest
Servers in the lab. Note these packages are not required to run Autotest in
the chroot."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

# These packages are meant to supply the dependencies to run Autotest.
RDEPEND="
	app-arch/pbzip2
	app-arch/unzip
	app-arch/xz-utils
	dev-db/mariadb
	dev-python/imaging
	dev-python/mysql-python
	dev-python/netifaces
	dev-python/pycrypto
	dev-python/setuptools
	dev-vcs/git
	dev-vcs/subversion
	sci-visualization/gnuplot
	www-servers/apache
	www-apache/mod_wsgi
"

# These packages are meant to supply the external Python library dependancies
# and other libraries usually provided by Autotest's build externals.
RDEPEND="
	${RDEPEND}
	chromeos-base/chromite
	dev-embedded/openocd
	dev-python/btsocket
	dev-python/django
	dev-python/dnspython
	dev-python/gdata
	dev-python/google-api-python-client
	dev-python/httplib2
	dev-python/jsonrpclib
	dev-python/matplotlib
	dev-python/mox
	dev-python/numpy
	dev-python/paramiko
	dev-python/python-gflags
	dev-python/python-uinput
	dev-python/pyshark
	dev-python/pyudev
	dev-python/requests
	dev-util/hdctools
"

DEPEND=""

S=${WORKDIR}
