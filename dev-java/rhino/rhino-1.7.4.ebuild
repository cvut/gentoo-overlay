# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
JAVA_PKG_IUSE="doc examples source"

inherit java-pkg-2 java-ant-2 eutils versionator

MY_PV="$(replace_version_separator 1 _ $(replace_version_separator 2 R))"
MY_P="${PN^}${MY_PV}_RELEASE"

DESCRIPTION="An open-source implementation of JavaScript written in Java."
HOMEPAGE="http://www.mozilla.org/rhino/"
SRC_URI="http://github.com/mozilla/${PN}/archive/${MY_P}.tar.gz"

LICENSE="MPL-2.0 GPL-2"
SLOT="1.6"
KEYWORDS="~amd64 ~x86"

IUSE=""

S="${WORKDIR}/rhino-${MY_P}"

RDEPEND="
	>=virtual/jre-1.5"
DEPEND="
	>=virtual/jdk-1.5
	app-arch/unzip"

src_prepare() {
	# Don't install e4x (ECMAScript for XML). It's an outdated beast and most
	# of people doesn't use it anyway.
	rm -r xmlimplsrc || die
}

src_install() {
	java-pkg_dojar build/${PN}${MY_PV}/js.jar

	java-pkg_dolauncher jsscript-${SLOT} \
		--main org.mozilla.javascript.tools.shell.Main

	use doc && java-pkg_dojavadoc "build/${PN}${MY_PV}/javadoc"
	use examples && java-pkg_doexamples examples
	use source && java-pkg_dosrc {src,toolsrc,testsrc}/org
}
