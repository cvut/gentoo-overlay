# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils

# Maintainer notes:
# - The newest tagged version 3.0.0-r1 is pretty old now and no newer version
#   has been released. Thus this ebuild sources my fork with some patches
#   included.

MY_PV="eb5fc5dd6281b05670d80f26f080cdb6fdf8824e"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Small RSA key management package, based on OpenSSL."
HOMEPAGE="https://github.com/OpenVPN/easy-rsa"
KEYWORDS="amd64 arm hppa ppc x86"
SRC_URI="https://github.com/jirutka/${PN}/archive/${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="3"
IUSE=""

DEPEND=">=dev-libs/openssl-1.0.0"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}/easyrsa3"

src_install() {
	dobin easyrsa
	insinto /usr/share/${PN}-${SLOT}
	doins -r vars.example openssl-1.0.cnf x509-types
}

pkg_postinst() {
	elog "Run 'easyrsa help', look in /usr/share/${P}/"
	elog "for configuration examples. Don't edit these files in-place, copy them!"
}
