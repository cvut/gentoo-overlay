# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

# Maintainer notes:
# - This ebuild supports Tomcat only for now.
# - When running on icedtea, liferay uses libmawt.so which is linked 
#   with libcups.so.2 from the cups package (in case of icedtea-bin at least),
#   therefore we need icedtea with USE cups for now :( 

inherit eutils java-utils-2 user

MY_PN="liferay-portal"
MY_PV="6.2-ce-ga2"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="Community Edition of Liferay, an enterprise shit you don't wanna use..."
HOMEPAGE="http://liferay.com/"
SRC_URI="mirror://sourceforge/lportal/${MY_PN}-tomcat-${MY_PV}-20140319114139101.zip"

LICENSE="LGPL-3"
SLOT="6.2"
KEYWORDS="~x86 ~amd64"

IUSE="+postgres +tomcat"
REQUIRED_USE="tomcat" # see notes

TOMCAT_SLOT="7"
ECJ_SLOT="3.7"

COMMON_DEP="
	>=www-servers/tomcat-7.0.29"
DEPEND="${COMMON_DEP}
	app-arch/unzip"
RDEPEND="${COMMON_DEP}
	>=virtual/jre-1.6
	>=virtual/jdk-1.6
	>=dev-java/tomcat-scripts-0.4
	dev-java/eclipse-ecj:${ECJ_SLOT}
	postgres? ( dev-java/jdbc-postgresql )"

MERGE_TYPE="binary"

S="${WORKDIR}/${MY_P}"

TOMCAT_HOME="/usr/share/tomcat-${TOMCAT_SLOT}"

MY_NAME="liferay-${SLOT}"
MY_USER="liferay"
MY_GROUP="liferay"

DEST_DIR="/opt/${MY_NAME}"
CONF_DIR="/etc/${MY_NAME}"
LOGS_DIR="/var/log/${MY_NAME}"
TEMP_DIR="/var/tmp/${MY_NAME}"

pkg_setup() {
	if [[ "$(java-pkg_get-current-vm)" =~ "icedtea-bin" ]]; then
		ewarn
		ewarn "When using IcedTea from binary package, make sure that you have"
		ewarn "emerged dev-java/icedtea-bin with USE flag 'cups'! Liferay uses"
		ewarn "libmawt.so which is linked with libcups.so.2 from the CUPS package."
		ewarn
	fi
    enewgroup ${MY_GROUP}
    enewuser ${MY_USER} -1 /bin/sh ${DEST_DIR} ${MY_GROUP}
}

src_prepare() {
	local libdir="${S}/$(basename tomcat-*)/webapps/ROOT/WEB-INF/lib"
	mkdir ${T}/portal-impl
	cd ${T}/portal-impl

	# replace code that uses internal and deprecated Sun JDK classes with 
	# proper implementation
	if ! [[ "$(java-pkg_get-current-vm)" =~ "oracle-jdk" ]]; then
		einfo "Replacing broken class in portal-impl.jar: ImageToolImpl.class"
		tar -xf ${FILESDIR}/portal-impl.jar-${PV}-fix-imagetool.tar \
			|| die "failed to unpack"
		jar uf ${libdir}/portal-impl.jar com \
			|| die "filed to replace class in portal-impl.jar"
		rm -Rf com
	fi

	chmod 644 ${libdir}/*
	cd ${S}
}

src_install() {
	local dest="${DEST_DIR}"
	local conf="${CONF_DIR}"

	if use postgres; then
		local db_driver="org.postgresql.Driver"
		local db_url="jdbc:postgresql://localhost:5432/liferay"
		local db_test_query="select 1"
		local db_dialect="org.hibernate.dialect.PostgreSQLDialect"
		local jdbc_jar="jdbc-postgresql"
	fi

	### Prepare directories ###

	diropts -m700
	keepdir ${dest}/data
	dodir ${TEMP_DIR}

	diropts -m750
	keepdir ${dest}/plugins
	dodir ${conf}/Catalina/localhost
	dodir ${dest}/{work,deploy}

	diropts -m755
	keepdir ${conf} ${LOGS_DIR}
	dodir ${dest}/portal


	### Install Tomcat instance ###

	insopts -m644
	insinto ${conf}

	# install server configs
	doins ${FILESDIR}/server.xml
	doins ${FILESDIR}/tomcat-logging.properties

	# install portal-context
	local tfile="portal-context.xml"
	cp ${FILESDIR}/${tfile} ${T} || die "failed to copy ${tfile}"
	sed -i \
		-e "s|@DOC_BASE@|${dest}/portal|" \
		-e "s|@DB_DRIVER@|${db_driver}|" \
		-e "s|@DB_URL@|${db_url}|" \
		-e "s|@DB_TEST_QUERY@|${db_test_query}|" \
		${T}/${tfile} || die "failed to filter ${tfile}"
	
	insinto ${conf}/Catalina/localhost
	newins ${T}/${tfile} ROOT.xml

	# make symlinks
	dosym ${TOMCAT_HOME}/conf/web.xml ${conf}/web.xml
	dosym ${conf}/Catalina/localhost/ROOT.xml ${conf}/portal-context.xml
	dosym ${conf} ${dest}/conf
	dosym ${LOGS_DIR} ${dest}/logs


	### Install Liferay ###

	cd tomcat-* || die

	# remove useless jars
	rm lib/ext/{mysql,postgresql}.jar
	rm webapps/ROOT/WEB-INF/lib/tomcat-jdbc.jar

	# install shared libs
	insinto ${dest}/lib
	doins lib/ext/*.jar

	# jars to temp
	insinto ${TEMP_DIR}
	doins -r temp/liferay

	# install portal
	# copying is slow, make hardlinks instead
	cp -rl webapps/ROOT/* ${D}${dest}/portal || die "failed to copy docbase"

	# install portal-ext.properties
	local tfile="portal-ext.properties"
	cp ${FILESDIR}/${tfile} ${T} || die "failed to copy ${tfile}"
	sed -i \
		-e "s|@DEST_DIR@|${dest}|" \
		-e "s|@CONF_DIR@|${conf}|" \
		${T}/${tfile} \
		|| die "failed to filter ${tfile}"
	
	insinto ${conf}
	doins ${T}/${tfile}
	dosym ${conf}/${tfile} ${dest}/${tfile}


	# fix permissions
	fowners -R ${MY_USER}:${MY_GROUP} ${dest} ${conf} ${TEMP_DIR} ${LOGS_DIR}
	fperms 640 ${conf}/{server.xml,portal-ext.properties}
	fperms 640 ${conf}/Catalina/localhost/ROOT.xml


	### RC scripts ###

	local path; for path in ${FILESDIR}/liferay-tc.*-r1; do
		cp ${path} ${T} || die "failed to copy ${path}"
		local tfile=${T}/$(basename ${path})
		sed -i \
			-e "s|@TOMCAT_SLOT@|${TOMCAT_SLOT}|" \
			-e "s|@CATALINA_HOME@|${TOMCAT_HOME}|" \
			-e "s|@CATALINA_BASE@|${dest}|" \
			-e "s|@EXTRA_JARS@|tomcat-servlet-api-3*,eclipse-ecj-3*${jdbc_jar:+,${jdbc_jar}}|" \
			-e "s|@TEMP_DIR@|${TEMP_DIR}|" \
			-e "s|@CONF_DIR@|${conf}|" \
			-e "s|@USER@|${MY_USER}|" \
			-e "s|@GROUP@|${MY_GROUP}|" \
			-e "s|@NAME@|Liferay ${SLOT}|" \
			${tfile} \
			|| die "failed to filter $(basename ${path})"
	done

	newinitd ${T}/liferay-tc.init-r1 ${MY_NAME}
	newconfd ${T}/liferay-tc.conf-r1 ${MY_NAME}
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
