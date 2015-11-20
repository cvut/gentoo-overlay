# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=4

JAVA_PKG_IUSE="doc source test"

inherit eutils java-pkg-2 java-ant-2 prefix user

MY_P="apache-${P}-src"

DESCRIPTION="Tomcat Servlet-3.0/JSP-2.2 Container"
HOMEPAGE="http://tomcat.apache.org/"
SRC_URI="mirror://apache/${PN}/tomcat-7/v${PV}/src/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="7"
KEYWORDS="~amd64 ~x86"
IUSE="extra-webapps"

RESTRICT="test" # can we run them on a production system?

ECJ_SLOT="3.7"
SAPI_SLOT="3.0"

COMMON_DEP="
	dev-java/eclipse-ecj:${ECJ_SLOT}
	~dev-java/tomcat-servlet-api-${PV}
	extra-webapps? ( dev-java/jakarta-jstl:0 )"
RDEPEND="${COMMON_DEP}
	!<dev-java/tomcat-native-1.1.20
	>=virtual/jre-1.6"
DEPEND="${COMMON_DEP}
	>=virtual/jdk-1.6
	>=dev-java/ant-core-1.8.1:0
	test? (
		dev-java/ant-junit:0
		dev-java/junit:4
	)"

S=${WORKDIR}/${MY_P}

pkg_setup() {
	java-pkg-2_pkg_setup
	enewgroup tomcat 265
	enewuser tomcat 265 -1 /dev/null tomcat
}

java_prepare() {
	find -name '*.jar' -exec rm -v {} + || die
	epatch "${FILESDIR}/${P}-build.xml.patch"

	# add system property 'catalina.webxml.default' to customize location
	# of the global web.xml
	epatch "${FILESDIR}/tomcat-7.0.32-ContextConfig.java-webxml.patch"

	# For use of catalina.sh in netbeans
	sed -i -e "/^# ----- Execute The Requested Command/ a\
		CLASSPATH=\`java-config --classpath ${PN}-${SLOT}\`" \
		bin/catalina.sh || die
}

JAVA_ANT_REWRITE_CLASSPATH="true"

EANT_BUILD_TARGET="deploy extras-jmx-remote"
EANT_GENTOO_CLASSPATH="tomcat-servlet-api-${SAPI_SLOT},eclipse-ecj-${ECJ_SLOT}"
EANT_GENTOO_CLASSPATH_EXTRA="${S}/output/classes"
EANT_NEEDS_TOOLS="true"
EANT_EXTRA_ARGS="-Dversion=${PV}-gentoo -Dversion.number=${PV} -Dcompile.debug=false"

src_compile() {
	EANT_GENTOO_CLASSPATH_EXTRA+=":$(java-pkg_getjar --build-only ant-core ant.jar)"
	java-pkg-2_src_compile
}

EANT_TEST_GENTOO_CLASSPATH="${EANT_GENTOO_CLASSPATH},junit-4"

src_test() {
	java-pkg-2_src_test
}

src_install() {
	local dest="/usr/share/${PN}-${SLOT}"
	local conf="/etc/${PN}-${SLOT}"

	java-pkg_jarinto "${dest}"/bin
	java-pkg_dojar output/build/bin/*.jar
	exeinto "${dest}"/bin
	doexe output/build/bin/*.sh

	java-pkg_jarinto "${dest}"/lib
	java-pkg_dojar output/build/lib/*.jar
	java-pkg_dojar output/extras/catalina-jmx-remote.jar

	# so we don't have to call java-config with --with-dependencies, which might
	# bring in more jars then actually desired.
	java-pkg_addcp "$(java-pkg_getjars eclipse-ecj-${ECJ_SLOT},tomcat-servlet-api-${SAPI_SLOT})"

	dodoc RELEASE-NOTES RUNNING.txt
	use doc && java-pkg_dojavadoc output/dist/webapps/docs/api
	use source && java-pkg_dosrc java/*

	### Webapps ###

	insinto "${dest}"/webapps
	doins -r output/build/webapps/{host-manager,manager,ROOT}
	use extra-webapps && doins -r output/build/webapps/{docs,examples}

	### Config ###

	# replace the default password with a random one, see #92281
	cp "${FILESDIR}"/server.xml "${T}"
	local randpw=$(echo ${RANDOM}|md5sum|cut -c 1-15)
	sed -i -e "s|SHUTDOWN|${randpw}|" "${T}"/server.xml || die "sed failed"

	# copy all configs to /usr/share/...
	insinto "${dest}"/conf
	doins -r output/build/conf/*

	# rewrite with our custom server.xml
	doins "${T}"/server.xml

	# copy shared configs to /etc/...
	insopts -m644 -o root -g tomcat
	insinto "${conf}"
	doins output/build/conf/{catalina.policy,catalina.properties,context.xml,web.xml}

	# create README file
	cat > "${T}"/README <<-'EOL'
		This directory contains shared config files and directories of Tomcat
		instances. To create a new instance run:
		    tomcat-instances create --suffix <INSTANCE_NAME>
	EOL
	doins "${T}"/README

	# create jmxremote configs with random password
	local randpw=$(echo ${RANDOM}|md5sum|cut -c 1-15)
	echo "tomcat ${randpw}" > "${T}"/jmxremote.passwd
	echo "tomcat readwrite" > "${T}"/jmxremote.access

	insopts -m640 -o root -g tomcat
	insinto "${conf}"
	doins "${T}"/jmxremote.*

	# filter and copy init, conf and tomcat-instances
	cp "${FILESDIR}"/tomcat{.conf,.init,-instances} "${T}" || die
	eprefixify "${T}"/tomcat{.conf,.init,-instances}
	sed -i -e "s|@SLOT@|${SLOT}|g" "${T}"/tomcat{.conf,.init,-instances} \
		|| die "sed failed"

	insopts -m644 -o root -g root
	insinto "${dest}"/gentoo
	doins "${T}"/tomcat.conf
	exeinto "${dest}"/gentoo
	doexe "${T}"/tomcat.init

	# install into /usr/bin
	dobin "${T}/tomcat-instances"
}

pkg_postinst() {
	elog "This package provides script for quick and easy creating and removing"
	elog "of Tomcat instances. Before you can run Tomcat server you must create"
	elog "at least one instance. Use command:"
	elog "    tomcat-instances help"
	elog "for more information.\n"

	ewarn "tomcat-dbcp.jar is not built at this time. Please fetch jar"
	ewarn "from upstream binary if you need it. Gentoo Bug # 144276"
}
