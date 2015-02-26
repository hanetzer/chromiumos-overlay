# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
PYTHON_COMPAT=( python2_7 )

inherit cros-constants gn-chromium multiprocessing python-single-r1 user

DESCRIPTION="mojo_shell, libraries, and codegen tools for use on CrOS"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"
IUSE="examples"

RDEPEND="dev-libs/glib
	dev-libs/libevent
	dev-libs/nspr
	dev-libs/nss"
DEPEND="${PYTHON_DEPS}
	${RDEPEND}"

# The git commit-id to build from. Use the special value "HEAD" to
# build from tip-of-tree.
MOJO_REVISION="HEAD"

pkg_setup() {
	gn-chromium_pkg_setup
}

pkg_preinst() {
	enewuser mojo
	enewgroup mojo
}

src_unpack() {
	export EGCLIENT="${EGCLIENT:-/mnt/host/depot_tools/gclient}"
	export DEPOT_TOOLS_UPDATE=0  # Prevents gclient from self-updating.
	cat > .gclient <<EOF
solutions = [
  { "name"        : "src",
    "url"         : "https://chromium.googlesource.com/external/mojo",
    "deps_file"   : "DEPS",
    "managed"     : False,
    "safesync_url": "",
  },
]
EOF
	local revopt=""
	if [ "$MOJO_REVISION" != "HEAD" ] ; then
	    revopt="--revision=${MOJO_REVISION}"
	fi
	"${EGCLIENT}" sync -j$(makeopts_jobs) --verbose --nohooks \
	    --transitive --reset --force --delete_unversioned_trees ${revopt}
	ln -s src "${S}"

	# Need to override the build/module_args/mojo.gni to force building
	# network service from source on Chrome OS.
	cd src && epatch "${FILESDIR}/mojo-build-gni.patch"
}

src_configure() {
	# TODO(benchan): Remove the following workaround, which disables
	# ccache to avoid running into a bug in gcc (crbug.com/450829).
	tc-export CC
	CC="${CC} -noccache"

	gn-chromium_src_configure
}

src_compile() {
	local targets
	targets=( mojo_shell mojo_launcher libmojo_sdk tracing )
	use examples && targets+=( examples/echo )
	ninja -C "$(gn-chromium_get_build_dir)" "${targets[@]}" || die
}

src_install() {
	# Mojo runtime.
	dosbin "$(gn-chromium_get_build_dir)/mojo_launcher"
	dosbin "$(gn-chromium_get_build_dir)/mojo_shell"

	# Init script.
	insinto /etc/init
	doins "${FILESDIR}"/*.conf

	# Mojo SDK library and headers.
	local d header_dirs=(
		mojo/public/cpp/application
		mojo/public/cpp/application/lib
		mojo/public/cpp/bindings
		mojo/public/cpp/bindings/lib
		mojo/public/cpp/environment
		mojo/public/cpp/system
		mojo/public/cpp/utility
		mojo/public/c/environment
		mojo/public/c/system
		mojo/public/platform/native
	)
	for d in "${header_dirs[@]}" ; do
		insinto /usr/include/${d}
		doins ${d}/*.h
	done
	local generated_dirs=( mojo/public/interfaces/application )
	for d in "${generated_dirs[@]}" ; do
		insinto /usr/include/${d}
		doins "$(gn-chromium_get_build_dir)/gen/${d}/"*.h
	done
	dolib.a "$(gn-chromium_get_build_dir)/obj/mojo/public/libmojo_sdk.a"

	# Location for Mojo applications.
	insinto /usr/lib/mojo
	doins "$(gn-chromium_get_build_dir)/tracing.mojo"
	use examples && doins "$(gn-chromium_get_build_dir)"/echo_{client,server}.mojo

	# Code generation tools, including GYP rules for mojom files.
	insinto /build/bin
	doins -r "mojo/public/tools/bindings"
}
