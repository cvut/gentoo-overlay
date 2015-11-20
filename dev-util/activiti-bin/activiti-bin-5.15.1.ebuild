# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

inherit eutils java-utils-2 tomcat

MY_PN="activiti"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Activiti is a light-weight workflow and Business Process
		Management (BPM) Platform targeted at business people, developers and system
		admins. Its core is a super-fast and rock-solid BPMN 2 process engine for Java."
HOMEPAGE="http://www.activiti.org/"
SRC_URI="https://github.com/Activiti/Activiti/releases/download/${MY_P}/${MY_P}.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 x86"

IUSE="+explorer +rest +postgres in-memory"
REQUIRED_USE="
	|| ( explorer rest )
	postgres? ( !in-memory )
	in-memory? ( !postgres )"

DEPEND=""
# Activiti Explorer requires JDK with Rhino (JavaScript engine).
RDEPEND="
	explorer? (
		|| (
			dev-java/icedtea[javascript]
			dev-java/oracle-jdk-bin
			dev-java/sun-jdk
		)
	)
	postgres? ( dev-java/jdbc-postgresql )"

MERGE_TYPE="binary"

S="${WORKDIR}/${MY_P}"

TOMCAT_INSTANCE="activiti"
TOMCAT_USER="activiti"

src_unpack() {
	unpack ${A}
	cd ${S}

	unzip -qd activiti-explorer wars/activiti-explorer.war
	unzip -qd activiti-rest wars/activiti-rest.war	
}

src_prepare() {
	sed 's/@NAME@/activiti-explorer/' ${FILESDIR}/log4j.properties \
		> activiti-explorer/WEB-INF/classes/log4j.properties \
		|| die "failed to filter log4j.properties"

	sed 's/@NAME@/activiti-rest/' ${FILESDIR}/log4j.properties \
		> activiti-rest/WEB-INF/classes/log4j.properties \
		|| die "failed to filter log4j.properties"

	rm activiti-{explorer,rest}/WEB-INF/classes/rebel.xml

	if ! use in-memory; then
		epatch ${FILESDIR}/${PN}-5.15.1-jndi-datasource.patch
		rm activiti-{explorer,rest}/WEB-INF/lib/commons-dbcp-*.jar
		rm activiti-{explorer,rest}/WEB-INF/lib/h2-*.jar
	fi
}

src_install() {
	# prepare directories and configs for Tomcat
	tomcat_prepare

	if use in-memory; then
		doconf activiti-explorer/WEB-INF/classes/db.properties
	else
		doconf ${FILESDIR}/{db.properties,server.xml}
	fi
	doconf ${FILESDIR}/context.xml

	rm activiti-{explorer,rest}/WEB-INF/classes/db.properties

	use explorer && newwar activiti-explorer explorer
	use rest && newwar activiti-rest rest

	# make symlinks for config
	local name; for name in explorer rest; do
		use ${name} || continue

		dosym ${TOMCAT_CONF}/db.properties \
			${TOMCAT_BASE}/webapps/${name}/WEB-INF/classes/db.properties
	done

	if use postgres; then
		local jdbc_jar="jdbc-postgresql"
	fi
	# add JDBC driver to classpath
	cp ${FILESDIR}/${MY_PN}.init ${T}
	sed -i \
		-e "s|\(tomcat_extra_jars=\).*|\1\"${jdbc_jar}\"|" \
		${T}/${MY_PN}.init || die "failed to filter ${MY_PN}.init"

	# install rc files
	tomcat_doinitd ${T}/${MY_PN}.init
	tomcat_doconfd ${MY_PN}.conf
}

pkg_postinst() {
	tomcat_pkg_postinst

	if use postgres; then
		elog
		elog "Activiti requires a SQL database to run. You have to edit jdbc/DataSource"
		elog "settings in ${TOMCAT_CONF}/server.xml and then create role and database for"
		elog "your Activiti instance."
		elog
		elog "If you have local PostgreSQL running, you can just copy&run:"
		elog "    su postgres"
		elog "    psql -c \"CREATE ROLE activiti PASSWORD 'activiti' \\"
		elog "        NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;\""
		elog "    createdb -E UTF-8 -O activiti activiti"
		elog "Note: You should change your password to something more random..."

	elif use in-memory; then
		elog
		elog "Activiti will run with H2 in-memory database. Please note that this is NOT"
		elog "recommended for production environment!"

	else
		ewarn
		ewarn "Activiti requires a SQL database to run. Since you have not set any database"
		ewarn "USE flag, you need to install an appropriate JDBC driver and add it to"
		ewarn "'tomcat_extra_jars' in /etc/init.d/${TOMCAT_INSTANCE}. Then you must edit"
		ewarn "jdbc/DataSource in ${CONF_DIR}/server.xml."
	fi

	elog
	elog "If this is a new installation, then use userId 'kermit' with password 'kermit'"
	elog "to login into Activiti."
}
