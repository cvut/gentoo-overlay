# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3} pypy2_0 )

inherit distutils-r1

DESCRIPTION="CLI client for Haste server (hastebin.com) written in Python."
HOMEPAGE="https://github.com/jirutka/haste-client https://pypi.python.org/pypi/haste-client"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	>=dev-python/docopt-0.3.0[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

DOCS=( README.md )
