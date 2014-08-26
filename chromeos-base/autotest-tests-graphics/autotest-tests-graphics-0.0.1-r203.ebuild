# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="29f7108a5447d14d7f2ee2f97c6d2c3cf2f6bfeb"
CROS_WORKON_TREE="3f5cb8cef04774c639a994dae1fc10acf0f7c4cf"
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
IUSE="+autotest"

RDEPEND="
	!<chromeos-base/autotest-tests-0.0.3
	chromeos-base/autotest-deps-glbench
	chromeos-base/autotest-deps-graphics
	tests_graphics_GLMark2? ( chromeos-base/autotest-deps-glmark2 )
	tests_graphics_Piglit? ( chromeos-base/autotest-deps-piglit )
	tests_graphics_PiglitBVT? ( chromeos-base/autotest-deps-piglit )
"
DEPEND="${RDEPEND}"

IUSE_TESTS="
	+tests_graphics_GLAPICheck
	+tests_graphics_GLBench
	+tests_graphics_GLMark2
	+tests_graphics_GpuReset
	+tests_graphics_KernelMemory
	+tests_graphics_LibDRM
	+tests_graphics_PerfControl
	+tests_graphics_Piglit
	+tests_graphics_PiglitBVT
	+tests_graphics_SanAngeles
	+tests_graphics_Sanity
	+tests_graphics_SyncControlTest
	+tests_graphics_VTSwitch
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
