# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

DESCRIPTION="Chromium OS CA Certificates PEM files"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

# This package cannot co-exist in the build target with
# app-misc/ca-certificates because of file conflicts.  Moreover,
# this package is a replacement for ca-certificates, so generally
# the two packages should not co-exist in any event.
#
# For maxiumum confusion, we depend on app-misc/ca-certificates from
# the build host for the "update-ca-certificates" script.  That
# dependency must be specified in chromeos-base/hard-host-depends,
# as there's no way with Portage to specify that dependency here (as
# of this writing, at any rate).
RDEPEND="!app-misc/ca-certificates"
DEPEND="$RDEPEND
	dev-libs/openssl"

# Because this ebuild has no source package, "${S}" doesn't get
# automatically created.  The compile phase depends on "${S}" to
# exist, so we make sure "${S}" refers to a real directory.
#
# The problem is apparently an undocumented feature of EAPI 4;
# earlier versions of EAPI don't require this.
S="${WORKDIR}"

src_unpack() {
	# Unpack the root cert tarball. The root certs are stored in the tree as
	# a tarball because that's the format provided to us by security; we
	# could store them unpacked, but then dropping the new certs is more of
	# a pain.
	tar xvjf "${FILESDIR}"/roots.tar.bz2
}

# N.B.  The cert files are in ${FILESDIR}, not a separate source
# code repo.  If you add or delete a cert file, you'll need to bump
# the revision number for this ebuild manually.
src_install() {
	insinto /usr/share/ca-certificates
	for x in "${S}"/roots/*.pem; do
		# Rename the certs by hash. The tarball names them by issuer
		# name, but some of these names have unicode in them, which
		# makes gmerge combust. Some day, this will be fixed.
		# crosbug.com/35982
		fp=$(openssl x509 -in "$x" -sha256 -fingerprint -noout \
		     | cut -f2 -d=)
		newins $x "$fp".crt
	done

	# Create required inputs to the update-ca-certificates script.
	dodir /etc/ssl/certs
	dodir /etc/ca-certificates/update.d
	(
		cd "${D}"/usr/share/ca-certificates
		find * -name '*.crt' | sort
	) > "${D}"/etc/ca-certificates.conf

	update-ca-certificates --root "${D}"
}
