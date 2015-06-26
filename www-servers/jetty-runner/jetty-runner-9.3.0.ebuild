# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit java-utils-2

MY_PV="${PV}.v20150612"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Fast and easy way to run Java web application from the command line."
HOMEPAGE="http://www.eclipse.org/jetty"
SRC_URI="http://central.maven.org/maven2/org/eclipse/jetty/${PN}/${MY_PV}/${MY_P}.jar"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 x86"

IUSE=""
MERGE_TYPE="binary"

RDEPEND=">=virtual/jre-1.8"
DEPEND=">=virtual/jdk-1.8"

S="${WORKDIR}"

src_unpack() {
	: # don't unpack JAR
}

src_install() {
	java-pkg_newjar "${DISTDIR}/${MY_P}.jar" "${PN}.jar"
	java-pkg_dolauncher

	newinitd "${FILESDIR}/jetty-runner.initd" jetty-runner
	newconfd "${FILESDIR}/jetty-runner.confd" jetty-runner
}
