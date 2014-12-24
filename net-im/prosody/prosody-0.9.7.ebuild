# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-im/prosody/prosody-0.9.3.ebuild,v 1.1 2014/03/15 13:46:23 klausman Exp $

EAPI=5

inherit flag-o-matic multilib versionator

MY_PV=$(replace_version_separator 3 '')
MY_P="${PN}-${MY_PV}"

MOD_AUTH_LDAP_PV="9a0a0cfd3710"
MOD_AUTH_LDAP_PN="mod_auth_ldap"
MOD_AUTH_LDAP_P="${MOD_AUTH_LDAP_PN}-${MOD_AUTH_LDAP_PV}"
MOD_AUTH_LDAP_URI="http://prosody-modules.googlecode.com/hg-history/${MOD_AUTH_LDAP_PV}/${MOD_AUTH_LDAP_PN}/${MOD_AUTH_LDAP_PN}.lua"

MOD_CARBONS_PV="7dbde05b48a9"
MOD_CARBONS_PN="mod_carbons"
MOD_CARBONS_P="${MOD_CARBONS_PN}-${MOD_CARBONS_PV}"
MOD_CARBONS_URI="http://prosody-modules.googlecode.com/hg-history/${MOD_CARBONS_PV}/${MOD_CARBONS_PN}/${MOD_CARBONS_PN}.lua"

MOD_SMACKS_PV="05fa54404012"
MOD_SMACKS_PN="mod_smacks"
MOD_SMACKS_P="${MOD_SMACKS_PN}-${MOD_SMACKS_PV}"
MOD_SMACKS_URI="http://prosody-modules.googlecode.com/hg-history/${MOD_SMACKS_PV}/${MOD_SMACKS_PN}/${MOD_SMACKS_PN}.lua"


DESCRIPTION="Prosody is a flexible communications server for Jabber/XMPP written in Lua."
HOMEPAGE="http://prosody.im/"
SRC_URI="http://prosody.im/tmp/${MY_PV}/${MY_P}.tar.gz
	ldap? ( ${MOD_AUTH_LDAP_URI} -> ${MOD_AUTH_LDAP_P} )
	carbons? ( ${MOD_CARBONS_URI} -> ${MOD_CARBONS_P} )
	smacks? ( ${MOD_SMACKS_URI} -> ${MOD_SMACKS_P} )"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="carbons ipv6 +jit ldap +libevent mysql postgres sqlite +smacks +ssl +zlib"

DEPEND="net-im/jabber-base
		!jit? ( >=dev-lang/lua-5.1 )
		jit? ( dev-lang/luajit )
		>=net-dns/libidn-1.1
		>=dev-libs/openssl-0.9.8"
RDEPEND="${DEPEND}
		dev-lua/luaexpat
		dev-lua/luafilesystem
		ipv6? ( >=dev-lua/luasocket-3 )
		!ipv6? ( dev-lua/luasocket )
		libevent? ( >=dev-lua/luaevent-0.4.3 )
		mysql? ( dev-lua/luadbi[mysql] )
		postgres? ( dev-lua/luadbi[postgres] )
		sqlite? ( dev-lua/luadbi[sqlite] )
		ssl? ( dev-lua/luasec )
		zlib? ( dev-lua/lua-zlib )
		ldap? ( dev-lua/lualdap )"

S=${WORKDIR}/${MY_P}

JABBER_ETC="/etc/jabber"
JABBER_SPOOL="/var/spool/jabber"
PROSODY_MODULES_DIR="/usr/$(get_libdir)/prosody/modules"

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.9.2-cfg.lua.patch"
	sed -i -e "s!MODULES = \$(DESTDIR)\$(PREFIX)/lib/!MODULES = \$(DESTDIR)\$(PREFIX)/$(get_libdir)/!"\
		-e "s!SOURCE = \$(DESTDIR)\$(PREFIX)/lib/!SOURCE = \$(DESTDIR)\$(PREFIX)/$(get_libdir)/!"\
		-e "s!INSTALLEDSOURCE = \$(PREFIX)/lib/!INSTALLEDSOURCE = \$(PREFIX)/$(get_libdir)/!"\
		-e "s!INSTALLEDMODULES = \$(PREFIX)/lib/!INSTALLEDMODULES = \$(PREFIX)/$(get_libdir)/!"\
		 Makefile || die
}

src_configure() {
	# the configure script is handcrafted (and yells at unknown options)
	# hence do not use 'econf'
	append-cflags -D_GNU_SOURCE
	luajit=""
	if use jit; then
		luajit="--runwith=luajit"
	fi
	./configure \
		--ostype=linux $luajit \
		--prefix="/usr" \
		--sysconfdir="${JABBER_ETC}" \
		--datadir="${JABBER_SPOOL}" \
		--with-lua-include=/usr/include \
		--with-lua-lib=/usr/$(get_libdir)/lua \
		--cflags="${CFLAGS} -Wall -fPIC" \
		--ldflags="${LDFLAGS} -shared" \
		--c-compiler="$(tc-getCC)" \
		--linker="$(tc-getCC)" \
		--require-config || die "configure failed"
}

src_install() {
	emake DESTDIR="${D}" install

	if use ldap; then
		insinto ${PROSODY_MODULES_DIR}
		newins "${DISTDIR}/${MOD_AUTH_LDAP_P}" ${MOD_AUTH_LDAP_PN}.lua
	fi
	if use carbons; then
		insinto ${PROSODY_MODULES_DIR}
		newins "${DISTDIR}/${MOD_CARBONS_P}" ${MOD_CARBONS_PN}.lua
	fi
	if use smacks; then
		insinto ${PROSODY_MODULES_DIR}
		newins "${DISTDIR}/${MOD_SMACKS_P}" ${MOD_SMACKS_PN}.lua
	fi

	newinitd "${FILESDIR}/${PN}".initd ${PN}
}

src_test() {
	cd tests || die
	./run_tests.sh || die
}
