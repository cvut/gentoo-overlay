# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit toolchain-funcs

DESCRIPTION="Openssl binding for Lua"
HOMEPAGE="https://github.com/zhaozg/lua-openssl"
SRC_URI="https://github.com/zhaozg/lua-openssl/archive/${PV}.tar.gz -> lua-openssl-${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+luajit"

RDEPEND="
	luajit? ( dev-lang/luajit:2 )
	!luajit? ( >=dev-lang/lua-5.1 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

use luajit && LUAV=luajit || LUAV=lua

src_prepare() {
	sed -r \
		-e 's|^CFLAGS(\s*)=|CFLAGS\1+=|' \
		-e 's|^LDFLAGS(\s*)=|LDFLAGS\1+=|' \
		-e "s|^CC=.*|CC=$(tc-getCC) \$(CFLAGS) -Ideps|" \
		-i Makefile || die "failed to filter Makefile"
}

src_compile() {
	local pkgconfig=$(tc-getPKG_CONFIG)
	emake \
		LUA_CFLAGS="$($pkgconfig --cflags $LUAV)" \
		LUA_LIBS="$($pkgconfig --libs $LUAV)" \
		LUA_LIBDIR="$($pkgconfig --variable INSTALL_CMOD $LUAV)" \
		|| die "emake failed"
}

src_install() {
	emake \
		LUA_LIBDIR="${D}$($(tc-getPKG_CONFIG) --variable INSTALL_CMOD $LUAV)" \
		install || die "emake install failed"
	dodoc README.md
}
