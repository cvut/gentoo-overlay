# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

EGIT_REPO_URI="https://github.com/jirutka/${PN}.git"

inherit git-2

DESCRIPTION="OpenNebula contextualization scripts."
HOMEPAGE="https://github.com/jirutka/one-context"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""

src_install() {
	local scripts_dir="/usr/share/one-context/scripts"

	insinto $scripts_dir
	doins scripts/*.sh

	rm scripts/*.sh
	exeinto $scripts_dir
	doexe scripts/*

	doinitd init.d/vmcontext
}
