# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit epatch toolchain-funcs

DESCRIPTION="Google's TensorFlow library for machine learning"
HOMEPAGE="https://www.tensorflow.org/"

# The versions of packages to use are chosen based on the contents of
# tensorflow/contrib/makefile/download_dependencies.sh
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${PN}-v${PV}.tar.gz
	http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/eigen-2355b229ea4c.tar.gz
	http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/gemmlowp-7c7c744640ddc3d0af18fb245b4d23228813a71b.zip
	http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/nsync-8502189abfa44c249c01c2cad64e6ed660a9a668.tar.gz
	http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/oourafft-20061228.tgz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

RDEPEND="dev-libs/protobuf"

DEPEND="${RDEPEND}
	dev-cpp/gtest
	dev-libs/re2
"

S="${WORKDIR}"

PATCHES=(
	"${FILESDIR}/tensorflow-1.5.0-nsync-makefile-clang.patch"
	"${FILESDIR}/tensorflow-1.5.0-tf-lite-protos.patch"
	"${FILESDIR}/tensorflow-1.5.0-tf-makefile-clang.patch"
)

# Prints the NSYNC architecture string that corresponds to the given portage
# architecture, or dies if the given portage architecture is not supported.
nsync_arch() {
	case $(tc-arch "$1") in
	amd64) echo "x86_64";;
	*) die "Unsupported arch"
	esac
}

MAKE_DIR="tensorflow/contrib/makefile"
DOWNLOADS_DIR="${MAKE_DIR}/downloads"

src_unpack() {
	default

	# Move dependencies into the location expected by the makefile.
	mv tensorflow*/* . || die
	mkdir "${DOWNLOADS_DIR}" || die
	mkdir "${DOWNLOADS_DIR}/eigen" && mv eigen*/* "${DOWNLOADS_DIR}/eigen" || die
	mkdir "${DOWNLOADS_DIR}/nsync" && mv nsync*/* "${DOWNLOADS_DIR}/nsync" || die
	mkdir "${DOWNLOADS_DIR}/fft2d" && mv fft*/* "${DOWNLOADS_DIR}/fft2d" || die
	mkdir "${DOWNLOADS_DIR}/gemmlowp" && mv gemmlowp*/* "${DOWNLOADS_DIR}/gemmlowp/" || die
}

src_prepare() {
	epatch "${PATCHES[@]}"

	# Add the explicit lite runtime option at the top of the option block for
	# every proto file. This is necessary since the available version of
	# protoc doesn't support the lite runtime flag.
	find tensorflow -name "*.proto" -exec \
		sed -E -i '0,/^option.*/s/(^option.*)/option optimize_for = LITE_RUNTIME;\n\1/' {} + || die
}

src_configure() {
	# Skip default configuration, which attempts to use Bazel.

	BUILD_NSYNC_ARCH="$(nsync_arch "${CBUILD}").linux.c++11"
	BOARD_NSYNC_ARCH="$(nsync_arch "${CHOST}").linux.c++11"
}

src_compile() {
	# Make nsync for the build environment.
	pushd "${DOWNLOADS_DIR}/nsync/builds/${BUILD_NSYNC_ARCH}" || die
	emake depend COMPILER=${CBUILD}
	emake depend nsync.a COMPILER=${CBUILD}
	# Clean up working files in case build and board arch are the same.
	cp nsync.a nsync_build.a || die
	emake clean
	popd || die

	# Make nsync for target board.
	# TODO(martis): For non-x86 target boards, we may have to import and use
	# the inline makefile from compile_nsync.sh.
	pushd "${DOWNLOADS_DIR}/nsync/builds/${BOARD_NSYNC_ARCH}" || die
	emake depend COMPILER=${CHOST}
	emake depend nsync.a COMPILER=${CHOST}
	popd || die

	# Make TensorFlow.
	emake -f tensorflow/contrib/makefile/Makefile \
		CBUILD="${CBUILD}" \
		CBOARD="${CHOST}" \
		HOST_NSYNC_LIB="${DOWNLOADS_DIR}/nsync/builds/${BUILD_NSYNC_ARCH}/nsync_build.a" \
		TARGET_NSYNC_LIB="${DOWNLOADS_DIR}/nsync/builds/${BOARD_NSYNC_ARCH}/nsync.a" \
		BOARD_CXXFLAGS="${CXXFLAGS}" \
		HOST_CXXFLAGS="--std=c++11 -march=native" \
		MAKEFILE_DIR="${MAKE_DIR}"
}

src_install() {
	# Collate and install TensorFlow headers. The files chosen for export are
	# based on the logic in
	# tensorflow/contrib/makefile/create_ios_frameworks.sh.
	local h_workdir="${WORKDIR}/header_work"
	mkdir "${h_workdir}" || die
	find tensorflow -name "*.h" -exec cp --parents {} "${h_workdir}" \; || die
	cp -R third_party "${h_workdir}" || die
	cp -p -R "${DOWNLOADS_DIR}/eigen/unsupported" "${h_workdir}/third_party/eigen3" || die
	cp -R "${DOWNLOADS_DIR}/eigen/Eigen" "${h_workdir}/third_party/eigen3" || die
	cp -R "${MAKE_DIR}/gen/proto" "${h_workdir}/tensorflow" || die
	rm -rf "${h_workdir}/${MAKE_DIR}" || die

	insinto /usr/include/tensorflow/
	doins -r "${h_workdir}"/*/
	dolib.a tensorflow/contrib/makefile/gen/lib/libtensorflow-core.a
}
