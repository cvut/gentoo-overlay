# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="Pre/post backup scripts."
HOMEPAGE="https://github.com/jirutka/prebackup"
SRC_URI="https://github.com/cvut/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
RDEPEND=">=app-shells/bash-4.0"

src_prepare() {
	sed -i -e 's|#!/usr/local/bin/prebackup|#!/usr/bin/prebackup|' lib/* || die
	sed -i -e 's|/usr/local/share/prebackup|/usr/share/prebackup|' bin/* || die
}

src_install() {
	dobin bin/*

	exeinto /usr/share/prebackup
	doexe lib/*
}
