# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit toolchain-funcs eutils git-r3

DESCRIPTION="OAuth 2.0 proxy for nginx written in Lua."
HOMEPAGE="https://github.com/jirutka/ngx-oauth"
SRC_URI=""

EGIT_REPO_URI="https://github.com/jirutka/ngx-oauth.git git@github.com:jirutka/ngx-oauth.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="luajit"

RDEPEND="
	www-servers/nginx[nginx_modules_http_lua]
	=dev-lua/lua-cjson-2*
	>=dev-lua/lua-resty-http-0.06
	dev-lua/luaossl"
DEPEND="${RDEPEND}
	virtual/pkgconfig"


src_compile() {
	: # do nothing
}

src_install() {
    local lua=lua
    use luajit && lua=luajit
    local pkgconfig="$(tc-getPKG_CONFIG)"
	local lmod="$($pkgconfig --variable INSTALL_LMOD $lua)" || die

	insinto "$lmod"
	doins -r lib/*

	einstalldocs
}
