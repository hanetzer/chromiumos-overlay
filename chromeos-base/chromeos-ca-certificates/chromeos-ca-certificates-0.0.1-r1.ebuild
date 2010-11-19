# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Chrome OS restricted set of certificates."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

src_install() {
	# c_rehash (OpenSSL 0.9.8l 5 Nov 2009) is processing just .pem files so
	# rename the certificates from .crt to .pem. An alternative is to use
	# openssl directly to create the hash symlinks:
	#
	#   ln -s $cert.crt $(openssl x509 -noout -hash < $cert.crt).0
	#
	# However, c_rehash has smarts about incrementing the .0 extension if
	# necessary.
	CA_CERT_DIR=/usr/share/chromeos-ca-certificates
	insinto "${CA_CERT_DIR}"
	for cert in \
	  Equifax_Secure_Certificate_Authority \
	  GeoTrustGlobalCA_crosssigned \
	  GoogleInternetAuthority; do
	  newins ${FILESDIR}/$cert.crt $cert.pem
	done
	c_rehash "${D}/${CA_CERT_DIR}"
}
