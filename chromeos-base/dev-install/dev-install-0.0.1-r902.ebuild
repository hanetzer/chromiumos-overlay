# Copyright 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# TODO(phobbs) the output of this ebuild depends on what virtual/target-os-dev
# depends on (except what is in virtual/target-os), but does NOT explicitly
# depend on those packages. Therefore any change to the dependencies of
# virtual/target-os-dev will result in a stale output of dev-install, breaking
# incremental builds.  See crbug.com/489895.

# This ebuild file installs the developer installer package. It:
#  + Copies dev_install.
#  + Copies some config files for emerge: make.defaults and make.conf.
#  + Generates a list of packages installed (in base images).
# dev_install downloads and bootstraps emerge in base images without
# modifying the root filesystem.

EAPI="4"
CROS_WORKON_COMMIT="ac89ce8102fd57983e4e1513f2b329f65c0bbc05"
CROS_WORKON_TREE="4dfe260e2f9b1cdc11c3710c7009fc6d5b7e7e99"
CROS_WORKON_PROJECT="chromiumos/platform/dev-util"
CROS_WORKON_LOCALNAME="dev"
CROS_WORKON_OUTOFTREE_BUILD="1"

inherit cros-workon cros-board multiprocessing

DESCRIPTION="Chromium OS Developer Packages installer"
HOMEPAGE="http://dev.chromium.org/chromium-os/how-tos-and-troubleshooting/install-software-on-base-images"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros-debug"

DEPEND="app-arch/tar
	sys-apps/coreutils
	sys-apps/grep
	sys-apps/portage
	sys-apps/sed"
# TODO(arkaitzr): remove dependency on tar if it's gonna be removed from the
# base image. Also modify dev_install.
RDEPEND="app-arch/tar
	net-misc/curl
	sys-apps/coreutils"

src_prepare() {
	SRCDIR="${S}/dev-install"
	mkdir -p "$(cros-workon_get_build_dir)"
}

src_compile() {
	cd "$(cros-workon_get_build_dir)"

	local useflags pkg pkgs BOARD=$(get_current_board_with_variant)

	if [[ -z "${BOARD}" ]]; then
		die "Could not determine the current board using cros-board.eclass."
	fi

	# We need to pass down cros-debug automatically because this is often
	# times toggled at the ./build_packages level.  This is a hack of sorts,
	# but covers the most common case.
	useflags="${USE}"
	use cros-debug || useflags+=" -cros-debug"

	pkgs=(
		# Generate a list of packages that go into the base image. These
		# packages will be assumed to be installed by emerge in the target.
		virtual/target-os

		# Get the list of the packages needed to bootstrap emerge.
		portage

		# Get the list of dev and test packages.
		virtual/target-os-dev
		virtual/target-os-test
	)
	ebegin "Building depgraphs for: ${pkgs[*]}"
	multijob_init
	for pkg in ${pkgs[@]} ; do
		# The ebuild env will modify certain variables in ways that we
		# do not care for.  For example, PORTDIR_OVERLAY is modified to
		# only point to the current tree which screws up the search of
		# the board-specific overlays.
		(
		multijob_child_init
		env -i PATH="${PATH}" PORTAGE_USERNAME="${PORTAGE_USERNAME}" USE="${useflags}" \
		emerge-${BOARD} \
			--root "${T}" --buildpkg=n \
			--pretend --quiet --emptytree --ignore-default-opts \
			--root-deps=rdeps ${pkg} | \
			egrep -o ' [[:alnum:]-]+/[^[:space:]/]+\b' | \
			tr -d ' ' | \
			sort > ${pkg##*/}.packages
		_pipestatus=${PIPESTATUS[*]}
		[[ ${_pipestatus// } -eq 0 ]] || die "\`USE=\"${useflags}\" emerge-${BOARD} ${pkg}\` failed"
		) &
		multijob_post_fork
	done
	multijob_finish
	eend
	# No virtual packages in package.provided. We store packages for
	# package.provided in file chromeos-base.packages as package.provided is a
	# directory.
	grep -v "virtual/" target-os.packages > chromeos-base.packages

	python "${FILESDIR}"/filter.py || die

	# Add the board specific binhost repository.
	sed -e "s|BOARD|${BOARD}|g" "${SRCDIR}/repository.conf" > repository.conf

	# Add dhcp to the list of packages installed since its installation will not
	# complete (can not add dhcp group since /etc is not writeable). Bootstrap it
	# instead.
	grep "net-misc/dhcp-" target-os-dev.packages >> chromeos-base.packages
	grep "net-misc/dhcp-" target-os-dev.packages >> bootstrap.packages
}

fixup_make_defaults() {
	local file=$1

	sed -i \
		-e "s/@IUSE_IMPLICIT@/${IUSE_IMPLICIT}/g" \
		-e "s/@ARCH@/${ARCH}/g" \
		-e "s/@ELIBC@/${ELIBC}/g" \
		-e "s/@USERLAND@/${USERLAND}/g" \
		-e "s/@KERNEL@/${KERNEL}/g" \
		-e "s/@USE_EXPAND_IMPLICIT@/${USE_EXPAND_IMPLICIT}/g" \
		${file} || die
}

src_install() {
	local build_dir=$(cros-workon_get_build_dir)

	cd "${SRCDIR}"
	dobin dev_install

	insinto /usr/share/${PN}/portage
	doins "${build_dir}"/{bootstrap.packages,repository.conf}

	insinto /usr/share/${PN}/portage/make.profile
	doins "${build_dir}"/package.installable make.{conf,defaults}

	fixup_make_defaults "${ED}"/usr/share/${PN}/portage/make.profile/make.defaults

	insinto /usr/share/${PN}/portage/make.profile/package.provided
	doins "${build_dir}"/chromeos-base.packages

	insinto /etc/env.d
	doins 99devinstall
	sed -i "s:@LIBDIR@:$(get_libdir):g" "${ED}"/etc/env.d/99devinstall

	# Python will be installed in /usr/local after running dev_install.
	# Ideally this should always work.  There's a minor bug that sometimes
	# shows up https://bugs.gentoo.org/380569 so work around it if need be.
	local pyver=$(eselect python show --ABI)
	if [[ -z ${pyver} ]]; then
		pyver=$(readlink "${SYSROOT}"/usr/bin/python2 | sed s:python::)
	fi
	dosym "/usr/local/bin/python${pyver}" "/usr/bin/python"
}

pkg_preinst() {
	if [[ $(cros_target) == "target_image" ]]; then
		# We don't want to install these files into the normal /build/
		# dir because we need different settings at build time vs what
		# we want at runtime in release images.  Thus, install the files
		# into /usr/share but symlink them into /etc for the images.
		local f srcdir="/usr/share/${PN}"
		pushd "${ED}/${srcdir}" >/dev/null
		for f in $(find -type f -printf '%P '); do
			dosym "${srcdir}/${f}" "/etc/${f}"
		done
		popd >/dev/null
	fi
}
