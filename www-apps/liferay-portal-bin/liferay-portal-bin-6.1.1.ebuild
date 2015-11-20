# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"

# Maintainer notes:
# - When running on icedtea, liferay uses libmawt.so which is linked 
#   with libcups.so.2 from the cups package (in case of icedtea-bin at least),
#   therefore we need icedtea with USE cups for now :(

inherit eutils

MY_PN="liferay-portal"
MY_PV="${PV}-ce-ga2"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="Community Edition of Liferay, open source enterprise portal"
HOMEPAGE="http://liferay.com/"
SRC_URI="mirror://sourceforge/lportal/${MY_PN}-tomcat-${MY_PV}-20120731132656558.zip"

LICENSE="LGPL-3"
SLOT="6.1"
KEYWORDS="~x86 ~amd64"
IUSE="+postgres"

TOMCAT_SLOT="7"

DEPEND="
	app-arch/unzip
	>=www-servers/tomcat-7.0.29"
RDEPEND="|| (
		>=dev-java/icedtea-bin-6[cups]
		>=dev-java/icedtea-6[cups]
		>=dev-java/oracle-jdk-bin-1.7
		>=dev-java/sun-jdk-1.6	)
	postgres? ( dev-java/jdbc-postgresql )"

S="${WORKDIR}/${MY_P}"

MY_NAME="liferay-${SLOT}"
MY_USER="liferay"
MY_GROUP="liferay"

TOMCAT_HOME="/usr/share/tomcat-${TOMCAT_SLOT}"
DEST_DIR="/opt/${MY_NAME}"
CONF_DIR="/etc/${MY_NAME}"

pkg_setup() {
	ebegin "Creating user and group"
    enewgroup ${MY_GROUP} \
		|| die "Unable to create ${MY_GROUP} group"
    enewuser ${MY_USER} -1 /bin/sh "${DEST_DIR}" ${MY_GROUP} \
		|| die "Unable to create ${MY_USER} user"
}

src_install() {
	local conf="${CONF_DIR}"
	local dest="${DEST_DIR}"
	local logs="/var/log/${MY_NAME}"
	local temp="/var/tmp/${MY_NAME}"


	### Prepare directories ###

	diropts -m700
	keepdir "${dest}"/data
	dodir "${temp}"

	diropts -m750
	keepdir "${dest}"/plugins
	dodir "${conf}"/Catalina/localhost
	dodir "${dest}"/{work,deploy}

	diropts -m755
	keepdir "${conf}" "${logs}"
	dodir "${dest}"/portal


	### Install Tomcat instance ###

	insopts -m644
	insinto "${conf}"

	## filter and install server.xml ##

	local tfile="server.xml"
	local randpw=$(echo ${RANDOM}|md5sum|cut -c 1-15)

	cp "${FILESDIR}/${tfile}" "${T}" || die
	sed -i \
		-e "s|@SHUTDOWN@|${randpw}|" \
		-e "s|@LOG_DIR@|${logs}|" \
		"${T}/${tfile}" \
		|| die "failed to filter ${tfile}"
	
	doins "${T}/${tfile}"

	## install tomcat-logging.properties ##

	insinto "${conf}"
	doins "${FILESDIR}"/tomcat-logging.properties

	## filter and install portal-context.xml ##

	local tfile="portal-context.xml"

	if use postgres; then
		local db_driver="org.postgresql.Driver"
		local db_url="jdbc:postgresql://localhost:5432/liferay"
		local db_test_query="select 1"
		local db_dialect="org.hibernate.dialect.PostgreSQLDialect"
		local jdbc_jar="jdbc-postgresql"
	fi

	cp "${FILESDIR}/${tfile}" "${T}" || die

	sed -i \
		-e "s|@DOC_BASE@|${dest}/portal|" \
		-e "s|@DB_DRIVER@|${db_driver}|" \
		-e "s|@DB_URL@|${db_url}|" \
		-e "s|@DB_TEST_QUERY@|${db_test_query}|" \
		"${T}/${tfile}" || die "failed to filter ${tfile}"
	
	insinto "${conf}"/Catalina/localhost
	newins "${T}/${tfile}" ROOT.xml

	## make symlinks ##

	dosym "${TOMCAT_HOME}"/conf/web.xml "${conf}"/web.xml
	dosym "${conf}"/Catalina/localhost/ROOT.xml "${conf}"/portal-context.xml
	dosym "${conf}" "${dest}"/conf
	dosym "${logs}" "${dest}"/logs


	### Install Liferay ###

	cd tomcat-* || die

	## install libs ##

	rm lib/ext/{mysql,postgresql}.jar
	rm webapps/ROOT/WEB-INF/lib/tomcat-jdbc.jar

	insinto "${dest}"/lib
	doins lib/ext/*.jar

	## install resin.jar and script-10.jar to temp ##

	insinto "${temp}"
	doins -r temp/liferay

	## deploy portal ##

	echo "    Deploying portal ..."
	# doins is slow so copy directly
	cp -r webapps/ROOT/* "${D}${dest}"/portal || die "failed to deploy portal"

	## filter and install portal-ext.properties ##

	local tfile="portal-ext.properties"

	cp "${FILESDIR}/${tfile}" "${T}" || die
	sed -i \
		-e "s|@DEST_DIR@|${dest}|" \
		-e "s|@CONF_DIR@|${conf}|" \
		"${T}/${tfile}" \
		|| die "failed to filter ${tfile}"
	
	insinto "${conf}"
	doins "${T}/${tfile}"
	dosym "${conf}/${tfile}" "${dest}/${tfile}"


	### Fix permissions ####

	fowners -R ${MY_USER}:${MY_GROUP} "${dest}" "${conf}" "${temp}" "${logs}"

	fperms 640 "${conf}"/{server.xml,portal-ext.properties}
	fperms 640 "${conf}"/Catalina/localhost/ROOT.xml


	### RC scripts ###

	cp "${FILESDIR}"/liferay-tc.conf "${T}" || die
	local tfile="${T}"/liferay-tc.conf

	local path; for path in "${FILESDIR}"/liferay-tc.*; do
		cp "${path}" "${T}" || die
		local tfile="${T}"/`basename ${path}`
		sed -i \
			-e "s|@TOMCAT_SLOT@|${TOMCAT_SLOT}|" \
			-e "s|@CATALINA_HOME@|${TOMCAT_HOME}|" \
			-e "s|@CATALINA_BASE@|${dest}|" \
			-e "s|@EXTRA_JARS@|tomcat-servlet-api-3*,eclipse-ecj-3*${jdbc_jar:+,${jdbc_jar}}|" \
			-e "s|@TEMP_DIR@|${temp}|" \
			-e "s|@CONF_DIR@|${conf}|" \
			-e "s|@USER@|${MY_USER}|" \
			-e "s|@GROUP@|${MY_GROUP}|" \
			-e "s|@NAME@|Liferay ${SLOT}|" \
			"${tfile}" \
			|| die "failed to filter `basename ${path}`"
	done

	newinitd "${T}"/liferay-tc.init "${MY_NAME}"
	newconfd "${T}"/liferay-tc.conf "${MY_NAME}"
}

pkg_postinst() {
	elog "Liferay Portal ${SLOT} requires a SQL database to run. You have to edit"
	elog "JDBC Data Source settings in '${CONF_DIR}/portal-context.xml' and then"
	elog "create role and database for your Liferay instance."
	elog

	if use postgres; then
		elog "If you have local PostgreSQL running, you can just copy&run:"
		elog "    su postgres"
		elog "    psql -c \"CREATE ROLE liferay PASSWORD 'liferay' \\"
		elog "        NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;\""
		elog "    createdb -E UTF-8 -O liferay liferay"
		elog "Note: You should change your password to something more random..."
	else
		ewarn "Since you have not set any database USE flag, you need to install" 
		ewarn "an appropriate JDBC driver and add it to TOMCAT_EXTRA_JARS in"
		ewarn "'/etc/conf.d/${MY_NAME}'."
		ewarn
		ewarn "Do not forgot to change driverClassName and DB URL in"
		ewarn "'${CONF_DIR}/portal-context.xml' as well."
	fi
}
