# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Scripts for Tomcat used by tomcat.eclass"
SRC_URI=""
HOMEPAGE="http://github.com/cvut/gentoo-overlay/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""

S="${WORKDIR}"

src_install() {
	insinto /usr/share/${PN}
	doins ${FILESDIR}/runscript{.conf,-simple.sh}
	doins ${FILESDIR}/logging-minimal.properties
	newins ${FILESDIR}/runscript.sh-${PV} runscript.sh
}
