# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="ba3fb170cd4291596b7f7f8c983863e97eaffbb9"
inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="Chrome OS Update Engine."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

RDEPEND="app-arch/bzip2
	chromeos-base/libchrome
	chromeos-base/metrics
	chromeos-base/verity
	dev-cpp/gflags
	dev-libs/glib
	dev-libs/libpcre
	dev-libs/libxml2
	dev-libs/protobuf
	dev-util/bsdiff
	net-misc/curl
	sys-apps/rootdev
	sys-libs/zlib"
DEPEND="chromeos-base/libchromeos
	dev-cpp/gmock
	dev-cpp/gtest
	dev-libs/dbus-glib
	${RDEPEND}"

src_compile() {
	tc-export CC CXX AR RANLIB LD NM
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	scons ${MAKEOPTS} || die "update_engine compile failed"
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	scons debug=1 \
		update_engine_unittests \
		test_http_server \
		|| die "failed to build tests"

	if ! use x86 ; then
		echo Skipping tests on non-x86 platform...
	else
		LIB_PATH="${SYSROOT}/usr/lib:${SYSROOT}/lib"
		LIBC_PATH="${SYSROOT}/usr/lib/gcc/${CHOST}/"$(gcc-fullversion)
		X11_PATH="${SYSROOT}/usr/lib/opengl/xorg-x11/lib"
		for test in *_unittests; do
			LD_LIBRARY_PATH="$LIB_PATH:$LIBC_PATH:$X11_PATH" \
				"${SYSROOT}/lib/ld-linux.so.2" "$test" \
				--gtest_filter='-*.RunAsRoot*:*.Fakeroot*' \
				|| die "$test failed"
		done
	fi
}

src_install() {
	dosbin update_engine
	dobin update_engine_client

	insinto /usr/share/dbus-1/services
	doins org.chromium.UpdateEngine.service

	insinto /etc/dbus-1/system.d
	doins UpdateEngine.conf

	insinto /usr/include/chromeos/update_engine
	doins update_engine.dbusserver.h
	doins update_engine.dbusclient.h

	# c_rehash (OpenSSL 0.9.8l 5 Nov 2009) is processing just .pem files so
	# rename the certificates from .crt to .pem. An alternative is to use
	# openssl directly to create the hash symlinks:
	#
	#   ln -s $cert.crt $(openssl x509 -noout -hash < $cert.crt).0
	#
	# However, c_rehash has smarts about incrementing the .0 extension if
	# necessary.
	CA_CERT_DIR=/usr/share/update_engine/ca-certificates
	insinto "${CA_CERT_DIR}"
	for cert in \
	  Equifax_Secure_Certificate_Authority \
	  GeoTrustGlobalCA_crosssigned \
	  GoogleInternetAuthority; do
	  newins certs/$cert.crt $cert.pem
	done
	c_rehash "${D}/${CA_CERT_DIR}"
}
