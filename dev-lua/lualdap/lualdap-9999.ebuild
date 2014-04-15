# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit base git-r3 toolchain-funcs

DESCRIPTION="Lua driver for LDAP"
HOMEPAGE="https://github.com/mwild1/lualdap/"
SRC_URI=""

EGIT_REPO_URI="https://github.com/mwild1/lualdap.git git://github.com/mwild1/lualdap.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="luajit"

RDEPEND="
	|| ( >=dev-lang/lua-5.1 dev-lang/luajit:2 )
	net-nds/openldap"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

DOCS=( "README" )

src_prepare() {
	local lua=lua;
	use luajit && lua=luajit;
	local pkgconfig=$(tc-getPKG_CONFIG)

	sed -r \
		-e "s|^(LUA_INC).*|\1=$(${pkgconfig} --variable includedir ${lua})|" \
		-e "s|^(LUA_LIBDIR).*|\1=$(${pkgconfig} --variable INSTALL_CMOD ${lua})|" \
		-e "s|^(OPENLDAP_INC).*|\1=/usr/include|" \
		-e "s|^(CC).*|\1=$(tc-getCC)|" \
		-i config || die "failed to filter config"
}
