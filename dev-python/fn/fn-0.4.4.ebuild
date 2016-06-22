# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 python3_{3,4,5} )

inherit distutils-r1 eutils

MY_PN="fn.py"
MY_P="${MY_PN}-${PV}"
DESCRIPTION="Implementation of missing features to enjoy functional programming in Python"
HOMEPAGE="https://pypi.python.org/pypi/fn.py"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="ASL-2.0"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND=""

S="${WORKDIR}/${MY_P}"
