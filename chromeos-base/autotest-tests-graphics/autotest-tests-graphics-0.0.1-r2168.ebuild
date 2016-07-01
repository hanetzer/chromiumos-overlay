# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="a90282aa0f57396c44303256029dcee9ade94855"
CROS_WORKON_TREE="f5ee2f8ce1cb79d9f41a095adecb69b7c4f29020"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="Graphics autotests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest ozone"

RDEPEND="
	!<chromeos-base/autotest-tests-0.0.3
	chromeos-base/autotest-deps-glbench
	chromeos-base/autotest-deps-graphics
	ozone? ( tests_graphics_Gbm? ( media-libs/minigbm ) )
	tests_graphics_GLMark2? ( chromeos-base/autotest-deps-glmark2 )
	tests_graphics_SanAngeles? ( media-libs/waffle )
	tests_graphics_Sanity? ( x11-libs/libdrm )
"
DEPEND="${RDEPEND}"

IUSE_TESTS="
	!ozone? (
		+tests_graphics_Piglit
		+tests_graphics_PiglitBVT
	)
	ozone? (
		+tests_graphics_dEQP
		+tests_graphics_Gbm
	)
	+tests_graphics_GLAPICheck
	+tests_graphics_GLBench
	+tests_graphics_GLMark2
	+tests_graphics_GpuReset
	+tests_graphics_KernelMemory
	+tests_graphics_LibDRM
	+tests_graphics_PerfControl
	+tests_graphics_SanAngeles
	+tests_graphics_Sanity
	+tests_graphics_SyncControlTest
	+tests_graphics_VTSwitch
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
