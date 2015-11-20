# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/avalon-logkit/avalon-logkit-2.1-r6.ebuild,v 1.1 2012/09/29 11:04:43 sera Exp $

EAPI=4

# Maintainer notes:
# - Most users doesn't need JavaMail and JMS support in avalon-logkit. These
#   jars are necessary only for compile, not in runtime, so we can make them
#   optional. All what we need are just "stubs" to fulfill dependencies for
#   compiler. I used these spec jars from the Geronimo project. I didn't make
#   ebuild for them and compile from sources because it would bring more
#   problems than benefits and it's really unnecessary. They're used only for
#   compiler, not bundled with the compiled avalon-logkit jar.
#
# - Tarball from mirrors was corrupted so I used direct link to
#   archive.apache.org and restricted mirror.
#

# JavaMail API
JAR_JAVAMAIL_PV="1.3.1-rc5"
JAR_JAVAMAIL_PN="geronimo-spec-javamail"
JAR_JAVAMAIL_P="${JAR_JAVAMAIL_PN}-${JAR_JAVAMAIL_PV}"
JAR_JAVAMAIL_URI="http://repo1.maven.org/maven2/geronimo-spec/${JAR_JAVAMAIL_PN}/${JAR_JAVAMAIL_PV}/${JAR_JAVAMAIL_P}.jar"

# JMS API
JAR_JMS_PV="1.1-rc4"
JAR_JMS_PN="geronimo-spec-jms"
JAR_JMS_P="${JAR_JMS_PN}-${JAR_JMS_PV}"
JAR_JMS_URI="http://repo1.maven.org/maven2/geronimo-spec/${JAR_JMS_PN}/${JAR_JMS_PV}/${JAR_JMS_P}.jar"


JAVA_PKG_IUSE="doc source test"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Easy-to-use Java logging toolkit"
HOMEPAGE="http://avalon.apache.org/"
SRC_URI="http://archive.apache.org/dist/excalibur/${PN}/source/${P}-src.tar.gz
	!javamail? ( ${JAR_JAVAMAIL_URI} )
	!jms? ( ${JAR_JMS_URI} )"

RESTRICT="mirror"

KEYWORDS="amd64 ~ppc ~ppc64 ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
LICENSE="Apache-2.0"
SLOT="2.0"
IUSE="javamail jms"

COMMON_DEP="
	dev-java/log4j:0
	java-virtuals/servlet-api:3.0
	javamail? ( java-virtuals/javamail:0 )
	jms? ( java-virtuals/jms:0 )"
RDEPEND="${COMMON_DEP}
	>=virtual/jre-1.4"
DEPEND="${COMMON_DEP}
	>=virtual/jdk-1.4
	test? ( dev-java/ant-junit )"

use javamail && use_javamail="yes"
use jms && use_jms="yes"


# avoid unpacking jars
src_unpack() {
	unpack "${P}-src.tar.gz"
	cd "${S}"
}

java_prepare() {
	# Doesn't like 1.6 / 1.7 changes to JDBC
	epatch "${FILESDIR}/${P}-java7.patch"

	java-ant_ignore-system-classes

	java-ant_xml-rewrite -f build.xml \
		-c -e available -a classpathref -v 'build.classpath' || die

	java-pkg_filter-compiler jikes

	# copy "stubs" to target/lib so compiler can find them, but only if
	# real implementations are not required by USE flags
	local libs="${S}/target/lib"
	if ! use javamail; then
		mkdir -p "${libs}"
		cp "${DISTDIR}/${JAR_JAVAMAIL_P}.jar" "${libs}" || die
	fi
	if ! use jms; then
		mkdir -p "${libs}"
		cp "${DISTDIR}/${JAR_JMS_P}.jar" "${libs}" || die
	fi
}

JAVA_ANT_REWRITE_CLASSPATH="yes"

EANT_GENTOO_CLASSPATH="log4j,servlet-api-3.0${use_javamail:+,javamail}${use_jms:+,jms}"

src_test() {
	java-pkg-2_src_test
}

src_install() {
	java-pkg_newjar target/${P}.jar
	use doc && java-pkg_dojavadoc dist/docs/api
	use source && java-pkg_dosrc src/java/*
}
