# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="This is a meta package for installing Chinese IME packages"
HOMEPAGE="http://www.google.com/inputtools/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="internal"

RDEPEND="internal? ( app-i18n/GoogleChineseInput-pinyin )
         internal? ( app-i18n/GoogleChineseInput-zhuyin )
         internal? ( app-i18n/GoogleChineseInput-cangjie )
         !internal? ( app-i18n/chromeos-cangjie )
         !internal? ( app-i18n/chromeos-pinyin )
         !internal? ( app-i18n/chromeos-zhuyin )"
DEPEND="${RDEPEND}"
