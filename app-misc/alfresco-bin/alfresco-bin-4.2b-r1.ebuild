# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
#

EAPI="5"

# Maintainer notes:
# - This ebuild supports Tomcat only for now.

inherit eutils tomcat

MY_PV="${PV%?}.${PV: -1}"  # ex. 4.2b -> 4.2.b
MY_P="alfresco-community-${MY_PV}"
MY_PN="alfresco"

DESCRIPTION="Alfresco Open Source Enterprise Content Management System"
HOMEPAGE="http://alfresco.com/"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.zip"

LICENSE="LGPL-3"
SLOT="4.2b"
KEYWORDS="~x86 ~amd64"

IUSE="+postgres +imagemagick +share +tomcat ooodirect"
REQUIRED_USE="tomcat" # see notes

DEPEND=""
RDEPEND="
	postgres? ( dev-java/jdbc-postgresql )
	imagemagick? ( media-gfx/imagemagick[jpeg,png,postscript,truetype] )
	ooodirect? (
		|| ( app-office/libreoffice
			app-office/libreoffice-bin
			app-office/openoffice-bin ) )"

MERGE_TYPE="binary"

S="${WORKDIR}"

TOMCAT_INSTANCE="${MY_PN}-${SLOT}"
TOMCAT_USER="alfresco"
TOMCAT_EXPAND_WAR="no"

src_prepare() {
    # fix permissions
    chmod -R a-x,a+X bin web-server

	sed -i \
		-e "s|tomcat/temp/|${TOMCAT_TEMP}/|g" \
		-e "s|tomcat/work/|${TOMCAT_BASE}/work/|g" \
		bin/clean_tomcat.sh || die "failed to filter clean_tomcat.sh"

	# fix logs location inside WARs
	# it is shame that this cannot be configured externally...
	local war; for war in ${WORKDIR}/web-server/webapps/{alfresco.war,share.war}; do
		local tfile="WEB-INF/classes/log4j.properties"
		local key='log4j.appender.File.File'
		local prefix='${catalina.base}/logs/'

		echo -n "    Patching log4j.properties in `basename ${war}` ..."

		cd ${T}
		jar xf ${war} ${tfile} || die "failed to extract ${tfile}"
		sed -i \
			-e "s|\(${key}=\)\(.*/\)\?\([\w\.]*\)|\1${prefix}\3|" \
			${tfile} || die "failed to modify log4j.properties"
		jar uf ${war} ${tfile} || die "failed to update ${tfile}"

		rm -Rf ${tfile}
		cd ${WORKDIR}

		echo "done"
	done
}

src_install() {
	# prepare directories and configs for Tomcat
	tomcat_prepare

	diropts -m750
	dodir ${TOMCAT_BASE}/data

	diropts -m755
	dodir ${TOMCAT_BASE}/shared/{lib,classes}

	insinto ${TOMCAT_BASE}/bin
	doins bin/*.jar

	exeinto ${TOMCAT_BASE}/bin
	doexe bin/clean_tomcat.sh

	cp ${FILESDIR}/generate_keystores.sh ${T}
	sed -i -e "s|@CONF_DIR@|${TOMCAT_CONF}|" \
		${T}/generate_keystores.sh \
		|| die "failed to filter generate_keystores.sh"

	doexe ${T}/generate_keystores.sh

	insinto ${TOMCAT_BASE}
	doins -r web-server/{endorsed,shared}

	# Copy WARs

	dowar web-server/webapps/alfresco.war
	if use share; then
		dowar web-server/webapps/share.war
	fi

	# Add classpaths to shared classloader in catalina.properties

	local tfile="catalina.properties"
	cp ${TOMCAT_HOME}/conf/${tfile} ${T} \
		|| die "failed to copy ${tfile} from ${TOMCAT_HOME}/conf"

	local path='${catalina.base}/shared/classes,${catalina.base}/shared/lib/\*\.jar'
	sed -i \
		-e "s|.*\(shared.loader=\).*|\1${path}|" \
		${T}/${tfile} || die "failed to filter ${tfile}"

	doconf ${T}/${tfile}

	# Copy configs

	doconf ${FILESDIR}/server.xml
	doconf ${FILESDIR}/tomcat-users.xml

	local tfile="alfresco-global.properties"
	cp ${FILESDIR}/${tfile} ${T} || die
	sed -i \
		-e "s|@DATA_DIR@|${TOMCAT_BASE}/data|" \
		-e "s|@CONF_DIR@|${TOMCAT_CONF}|" \
		${T}/${tfile} || die "failed to filter ${tfile}"
	if use ooodirect; then
		sed -i -e "s|.*\(ooo.enabled=\).*|\1true|" \
			${T}/${tfile} || die "failed to filter ${tfile}"
	fi
	doconf ${T}/${tfile}

	confinto Catalina/localhost
	newconf ${FILESDIR}/alfresco-context-pg.xml alfresco.xml

	# Copy default keystores from alfresco.war

	local keystore="WEB-INF/classes/alfresco/keystore"

	cd ${T}
	jar xf ${WORKDIR}/web-server/webapps/alfresco.war ${keystore} \
		|| die "failed to extract ${keystore} from alfresco.war"
	rm ${keystore}/{CreateSSLKeystores.txt,generate_keystores.*}

	confinto keystore
	doconf ${keystore}/*

	cd ${WORKDIR}

	# Make symlinks and fix perms

	dosym ${TOMCAT_CONF}/alfresco-global.properties \
		${TOMCAT_BASE}/shared/classes/alfresco-global.properties
	dosym ${TOMCAT_CONF}/Catalina/localhost/alfresco.xml ${TOMCAT_CONF}/alfresco-context.xml

	fowners -R ${TOMCAT_USER}:${TOMCAT_GROUP} ${TOMCAT_BASE}/{data,shared}
	fowners -R root:${TOMCAT_GROUP} ${TOMCAT_CONF}/keystore
	fperms 640 ${TOMCAT_CONF}/{server.xml,tomcat-users.xml,alfresco-global.properties}
	fperms 750 ${TOMCAT_CONF}/keystore

	# Install RC files

	if use postgres; then
		local jdbc_jar="jdbc-postgresql"
	fi
	# add JDBC driver to classpath
	cp ${FILESDIR}/alfresco.init ${T}
	sed -i \
		-e "s|\(tomcat_extra_jars=\).*|\1\"${jdbc_jar}\"|" \
		${T}/alfresco.init || die "failed to filter alfresco.init"

	tomcat_doinitd ${T}/alfresco.init
	tomcat_doconfd alfresco.conf
}

pkg_postinst() {
	tomcat_pkg_postinst

	elog "Alfresco ${SLOT} requires a SQL database to run. You have to edit"
	elog "JDBC Data Source settings in '${TOMCAT_CONF}/alfresco-context.xml' and then"
	elog "create role and database for your Alfresco instance."
	elog

	if use postgres; then
		elog "If you have local PostgreSQL running, you can just copy&run:"
		elog "    su postgres"
		elog "    psql -c \"CREATE ROLE alfresco PASSWORD 'alfresco' \\"
		elog "        NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;\""
		elog "    createdb -E UTF-8 -O alfresco alfresco"
		elog "Note: You should change your password to something more random..."
	else
		ewarn "Since you have not set any database USE flag, you need to install"
		ewarn "an appropriate JDBC driver and add it to tomcat_extra_jars in"
		ewarn "'/etc/init.d/${TOMCAT_INSTANCE}'. Then you must edit"
		ewarn "'${TOMCAT_CONF}/alfresco-context.xml' and change driverClassName,"
		ewarn "validationQuery, url and Hibernate dialect."
	fi

	elog
    elog "Keystores in ${TOMCAT_CONF}/keystore was populated with"
    elog "default certificates provided by Alfresco, Ltd. If you are going to"
	elog "use SOLR, in production environment, you should generate your own"
	elog "certificates and keystores. You can use provided script:"
	elog "    ${TOMCAT_BASE}/bin/generate_keystores.sh"
}
