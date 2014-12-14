# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Async Resolver Library from OpenBSD/OpenSMTPD"
HOMEPAGE="https://github.com/OpenSMTPD/libasr"
SRC_URI="https://www.opensmtpd.org/archives/${P}.tar.gz"

LICENSE="ISC BSD BSD-1 BSD-2 BSD-4"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-libs/openssl"
RDEPEND="${DEPEND}"
