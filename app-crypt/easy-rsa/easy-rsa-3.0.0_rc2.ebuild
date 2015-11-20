# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

MY_PV="${PV/_/-}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Small RSA key management package, based on OpenSSL."
HOMEPAGE="https://github.com/OpenVPN/easy-rsa"
KEYWORDS="amd64 x86"
SRC_URI="https://github.com/OpenVPN/easy-rsa/archive/v${MY_PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="3"
IUSE="doc"

DEPEND=">=dev-libs/openssl-1.0.0"
RDEPEND="$DEPEND"

S="${WORKDIR}/${MY_P}"

DEST="/usr/share/${PN}-${SLOT}"

src_prepare() {
	epatch "${FILESDIR}/${P}-avoid-files-corruption-on-error.patch"
	epatch "${FILESDIR}/${P}-locate-vars-in-working-dir.patch"
	epatch "${FILESDIR}/${P}-use-aes256-as-default.patch"
	epatch "${FILESDIR}/${P}-vars.example.patch"
}

src_install() {
	if use doc; then
		dodoc -r README.quickstart.md KNOWN_ISSUES COPYING ChangeLog doc/*
	fi
	cd easyrsa3

	dobin easyrsa

	insinto $DEST
	doins -r vars.example openssl-1.0.cnf x509-types
}

pkg_postinst() {
	elog "Copy ${DEST}/vars.example into your PKI directory, rename"
	elog "it to 'vars' and edit. Run 'easyrsa help' for more information."
}
