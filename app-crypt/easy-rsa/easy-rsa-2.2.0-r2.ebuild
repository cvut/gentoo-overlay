# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

inherit eutils

DESCRIPTION="Small RSA key management package, based on OpenSSL."
HOMEPAGE="http://openvpn.net/"
KEYWORDS="amd64 arm hppa ppc x86"
SRC_URI="http://swupdate.openvpn.net/community/releases/${P}_master.tar.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE="san"

DEPEND=">=dev-libs/openssl-0.9.6"
RDEPEND="${DEPEND}
		!<net-misc/openvpn-2.3"

S="${WORKDIR}/${P}_master"

src_prepare() {
	epatch "${FILESDIR}/${PN}-2.0.0-pkcs11.patch"
	epatch "${FILESDIR}/no-licenses.patch"

	# http://www.msquared.id.au/articles/easy-rsa-subjectaltname/
	use san && epatch "${FILESDIR}/${PN}-2.0.0-san.patch"
}

src_configure() {
	econf --docdir="${EPREFIX}/usr/share/doc/${PF}"
}

src_install() {
	emake DESTDIR="${D}" install
	doenvd "${FILESDIR}/65easy-rsa" # config-protect easy-rsa
}
