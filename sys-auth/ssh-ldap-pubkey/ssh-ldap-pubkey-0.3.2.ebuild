# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} pypy2_0 )

inherit distutils-r1

DESCRIPTION="Utility to manage SSH public keys stored in LDAP."
HOMEPAGE="https://github.com/jirutka/ssh-ldap-pubkey https://pypi.python.org/pypi/ssh-ldap-pubkey"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/python-ldap[${PYTHON_USEDEP}]
	>=dev-python/docopt-0.3.0[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

DOCS=( README.md )


src_install() {
	distutils-r1_src_install

	# do not rewrite existing ldap.conf from nsswitch
	if [ ! -f /etc/ldap.conf ]; then
		insinto /etc
		doins etc/ldap.conf
	fi

	if [ -d /etc/openldap/schema ]; then
		insinto /etc/openldap/schema
		doins etc/openssh-lpk.schema
	fi
}

pkg_postinst() {
	einfo "To configure sshd to fetch user authorized keys from LDAP server add this"
	einfo "to /etc/ssh/sshd_config:"
	einfo "    AuthorizedKeysCommand /usr/bin/ssh-ldap-pubkey-wrapper"
	einfo "    AuthorizedKeysCommandUser nobody"
	einfo
}
