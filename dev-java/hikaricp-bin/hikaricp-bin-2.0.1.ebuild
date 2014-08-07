# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit java-utils-2

MY_PN="HikariCP-java6"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A solid high-performance JDBC connection pool at last."
HOMEPAGE="http://brettwooldridge.github.io/HikariCP/"
SRC_URI="http://repo2.maven.org/maven2/com/zaxxer/${MY_PN}/${PV}/${MY_P}.jar"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 x86"

IUSE=""
MERGE_TYPE="binary"

RDEPEND=">=virtual/jre-1.6"
DEPEND=">=virtual/jdk-1.6"

S="${WORKDIR}"

src_unpack() {
	: # don't unpack JAR
}

src_install() {
	java-pkg_newjar "${DISTDIR}/${MY_P}.jar" "${MY_PN}.jar" || die
}
