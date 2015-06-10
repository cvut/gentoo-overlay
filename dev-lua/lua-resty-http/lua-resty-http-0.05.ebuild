# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit toolchain-funcs eutils

DESCRIPTION="Lua HTTP client cosocket driver for ngx_lua."
HOMEPAGE="https://github.com/pintsized/lua-resty-http"
SRC_URI="https://github.com/pintsized/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="luajit"

RDEPEND="
	www-servers/nginx[nginx_modules_http_lua]"
DEPEND="${RDEPEND}
	virtual/pkgconfig"


src_compile() {
	: # do nothing
}

src_install() {
    local lua=lua
    use luajit && lua=luajit
    local pkgconfig=$(tc-getPKG_CONFIG)
	local lmod=$($pkgconfig --variable INSTALL_LMOD $lua) || die

	insinto $lmod/resty
	doins lib/resty/*.lua
}
