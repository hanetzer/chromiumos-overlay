# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/mysql-python/mysql-python-1.2.3-r1.ebuild,v 1.12 2014/02/06 09:27:32 jer Exp $

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7} )

inherit distutils-r1 flag-o-matic

MY_P="MySQL-python-${PV}"

DESCRIPTION="Python interface to MySQL"
HOMEPAGE="http://sourceforge.net/projects/mysql-python/ http://pypi.python.org/pypi/MySQL-python"
SRC_URI="mirror://sourceforge/mysql-python/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

# RDEPEND on sys-devel/binutils to ensure libbfd is available.
RDEPEND="virtual/mysql
	sys-devel/binutils
"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]"

S="${WORKDIR}/${MY_P}"

DOCS=( HISTORY README doc/{FAQ,MySQLdb}.txt )

src_configure() {
	# Append the SYSROOT Library Path in order for the linker to find
        # libbfd when cross-compiling. 
	append-ldflags "-L${SYSROOT}/usr/${CHOST}/lib"
	
	# Update the site configuration options to search for mysql_config in the SYSROOT.
	sed -i -r \
		-e "s:#mysql_config = /usr/local/bin:mysql_config = ${SYSROOT}/usr/bin:" \
		site.cfg
	distutils-r1_src_configure
}

python_configure_all() {
	append-flags -fno-strict-aliasing
}
