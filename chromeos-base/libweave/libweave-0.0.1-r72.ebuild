# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="5cc5341ba65bdbc088cb6d98e64dd307e28240b4"
CROS_WORKON_TREE="867cc47cb55eb87c44706b2b3ba7df64316afaa5"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="libweave"

inherit cros-workon libchrome platform

DESCRIPTION="Weave device library"
HOMEPAGE="http://dev.chromium.org/chromium-os/platform"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

COMMON_DEPEND="
  chromeos-base/libchromeos
"

RDEPEND="
  ${COMMON_DEPEND}
"

DEPEND="
  ${COMMON_DEPEND}
  dev-cpp/gmock
  dev-cpp/gtest
"

src_install() {
  insinto "/usr/$(get_libdir)/pkgconfig"

  # Install libraries.
  local v
  for v in "${LIBCHROME_VERS[@]}"; do
    ./platform2_preinstall.sh "${OUT}" "${v}"
    dolib.so "${OUT}"/lib/libweave-"${v}".so
    doins "${OUT}"/lib/libweave-*"${v}".pc
    dolib.a "${OUT}"/libweave-test-"${v}".a
  done

  # Install header files.
  insinto /usr/include/weave
  doins include/weave/*.h

  insinto /usr/include/weave/test
  doins include/weave/test/*.h
}

platform_pkg_test() {
  platform_test "run" "${OUT}/libweave_testrunner"
  platform_test "run" "${OUT}/libweave_base_testrunner"
  platform_test "run" "${OUT}/libweave_exports_testrunner"
  platform_test "run" "${OUT}/libweave_base_exports_testrunner"
}
