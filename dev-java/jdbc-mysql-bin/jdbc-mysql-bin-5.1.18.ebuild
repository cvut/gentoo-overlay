# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit java-utils-2

MY_PN="mysql-connector-java"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="MySQL JDBC driver"
HOMEPAGE="http://www.mysql.com/products/connector/j/"
SRC_URI="mirror://mysql/Downloads/Connector-J/${MY_P}.tar.gz"

LICENSE="GPL-2-with-MySQL-FLOSS-exception"
SLOT="0"
KEYWORDS="amd64 x86"

IUSE=""
MERGE_TYPE="binary"

RDEPEND=">=virtual/jre-1.6"
DEPEND=">=virtual/jdk-1.6"

S="${WORKDIR}/${MY_P}"

src_install() {
	java-pkg_newjar ${MY_P}-bin.jar ${PN/-bin/}.jar || die
	dodoc README CHANGES
	dohtml docs/*.html
}
