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

# Google Docs integration
GDOCS_AMP_PV="2.0.4-31c"
GDOCS_REPO_AMP_P="alfresco-googledocs-repo-${GDOCS_AMP_PV}"
GDOCS_REPO_AMP_URI="mirror://sourceforge/${MY_PN}/${GDOCS_REPO_AMP_P}.amp"
GDOCS_SHARE_AMP_P="alfresco-googledocs-share-${GDOCS_AMP_PV}"
GDOCS_SHARE_AMP_URI="mirror://sourceforge/${MY_PN}/${GDOCS_SHARE_AMP_P}.amp"

# Solr for Alfresco
SOLR_P="alfresco-community-solr-${MY_PV}"
SOLR_URI="mirror://sourceforge/${MY_PN}/${SOLR_P}.zip"
SOLR_WD="${WORKDIR}/${SOLR_P}"

DESCRIPTION="Alfresco Open Source Enterprise Content Management System"
HOMEPAGE="http://alfresco.com/"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.zip
	googledocs? ( ${GDOCS_REPO_AMP_URI} -> ${GDOCS_REPO_AMP_P}.amp
	              ${GDOCS_SHARE_AMP_URI} -> ${GDOCS_SHARE_AMP_P}.amp )
	solr? ( ${SOLR_URI} -> ${SOLR_P}.zip )"

LICENSE="LGPL-3"
SLOT="4.2d"
KEYWORDS="~x86 ~amd64"

IUSE="+postgres +imagemagick +share +solr +tomcat googledocs ooodirect"
REQUIRED_USE="tomcat" # see notes

DEPEND=""
RDEPEND="
	>=virtual/jdk-1.7
	postgres? ( dev-java/jdbc-postgresql )
	imagemagick? ( media-gfx/imagemagick[jpeg,png,postscript,truetype] )
	ooodirect? (
		|| ( app-office/libreoffice
			app-office/libreoffice-bin
			app-office/openoffice-bin ) )"

MERGE_TYPE="binary"

S="${WORKDIR}/${MY_P}"

TOMCAT_INSTANCE="${MY_PN}-${SLOT}"
TOMCAT_USER="alfresco"
TOMCAT_EXPAND_WAR="no"

alfresco-mmt() {
	echo -n "    Applying $(basename $1) on $(basename $2) ..."
	java -jar ${S}/bin/alfresco-mmt.jar install $@ -nobackup \
		|| die "failed to apply $(basename $1)"
	echo "done"
}

src_unpack() {
	if use solr; then
		mkdir ${SOLR_WD}
		cd ${SOLR_WD}
		unpack ${SOLR_P}.zip
	fi

	mkdir ${S}
	cd ${S}
	unpack ${MY_P}.zip
}

src_prepare() {
	# it must by here, because TOMCAT_BASE is initialized in pkg_setup phase
	DATA_DIR="${TOMCAT_BASE}/data"
	SOLR_DIR="${TOMCAT_BASE}/solr"

	local webapps=${S}/web-server/webapps
	local solrwar; use solr && solrwar=${SOLR_WD}/apache-solr-1.4.1.war

    # fix permissions
    chmod -R a-x,a+X bin web-server

	if use googledocs; then
		alfresco-mmt ${DISTDIR}/${GDOCS_REPO_AMP_P}.amp ${webapps}/alfresco.war
		use share && alfresco-mmt ${DISTDIR}/${GDOCS_SHARE_AMP_P}.amp ${webapps}/share.war
	fi

	if use solr; then
		sed -i \
			-e "s|@@ALFRESCO_SOLR_DIR@@|${SOLR_DIR}|" \
			-e 's|debug="0" ||' \
			${SOLR_WD}/context.xml || die "failed to filter SOLR context.xml"

		local core; for core in archive workspace; do
			local cron="0 0/1 * * * ? *"

			# add prefix for keystore path and set more reasonable cron timer
			sed -i \
				-e "s|@@ALFRESCO_SOLR_DIR@@|${DATA_DIR}/solr|" \
				-e "s|\(store.location=\)\(.*\)|\1keystore/\2|" \
				-e "s|\(passwordFileLocation=\)\(.*\)|\1keystore/\2|" \
				-e "s|\(alfresco.cron=\).*|\1${cron}|" \
				${SOLR_WD}/${core}-SpacesStore/conf/solrcore.properties \
				|| die "failed to filter solrcore.properties"
		done
	fi

	# fix logs location inside WARs
	# it is shame that this cannot be configured externally...
	local war; for war in ${webapps}/{alfresco.war,share.war} ${solrwar}; do
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

		rm -R ${tfile}
		cd ${S}

		echo "done"
	done
}

src_install() {
	# prepare directories and configs for Tomcat
	tomcat_prepare

	diropts -m750
	dodir ${DATA_DIR}
	use solr && dodir ${DATA_DIR}/solr

	diropts -m755
	dodir ${TOMCAT_BASE}/shared/{lib,classes/alfresco}
	dodir ${TOMCAT_BASE}/clib

	insinto ${TOMCAT_BASE}/bin
	doins bin/*.jar

	exeinto ${TOMCAT_BASE}/bin

	cp ${FILESDIR}/generate_keystores.sh ${T}
	sed -i "s|@CONF_DIR@|${TOMCAT_CONF}|" \
		${T}/generate_keystores.sh \
		|| die "failed to filter generate_keystores.sh"

	doexe ${T}/generate_keystores.sh

	insinto ${TOMCAT_BASE}
	doins -r web-server/endorsed

	# Copy WARs

	dowar web-server/webapps/alfresco.war
	use share && dowar web-server/webapps/share.war

	# Add classpaths to shared classloader in catalina.properties

	local tfile="catalina.properties"
	cp ${TOMCAT_HOME}/conf/${tfile} ${T} \
		|| die "failed to copy ${tfile} from ${TOMCAT_HOME}/conf"

	local path='${catalina.base}/shared/classes,${catalina.base}/shared/lib/\*\.jar'
	sed -Ei \
		-e "s|.*(shared.loader=).*|\1${path}|" \
		${T}/${tfile} || die "failed to filter ${tfile}"

	doconf ${T}/${tfile}

	# Copy configs

	local dir; for dir in web-server/shared/classes/alfresco/*; do
		local name=$(basename ${dir})
		doconf -r ${dir}
		dosym ${TOMCAT_CONF}/${name} ${TOMCAT_BASE}/shared/classes/alfresco/${name}
	done

	doconf ${FILESDIR}/server.xml
	doconf ${FILESDIR}/tomcat-users.xml

	local tfile="alfresco-global.properties"
	cp ${FILESDIR}/${tfile}-r1 ${T}/${tfile} || die
	sed -i \
		-e "s|@DATA_DIR@|${DATA_DIR}|" \
		-e "s|@CONF_DIR@|${TOMCAT_CONF}|" \
		-e "s|@BASE_DIR@|${TOMCAT_BASE}|" \
		${T}/${tfile} || die "failed to filter ${tfile}"
	if use ooodirect; then
		sed -Ei \
			-e "s|.*(ooo.enabled=).*|\1true|" \
			${T}/${tfile} || die "failed to filter ${tfile}"
	fi
	if use solr; then
		sed -Ei \
			-e "s|.*(index.subsystem.name=).*|\1solr|" \
			${T}/${tfile} || die "failed to filter ${tfile}"
	fi
	doconf ${T}/${tfile}

	# Copy default keystores from alfresco.war

	local keystore="WEB-INF/classes/alfresco/keystore"

	cd ${T}
	jar xf ${S}/web-server/webapps/alfresco.war ${keystore} \
		|| die "failed to extract ${keystore} from alfresco.war"
	rm ${keystore}/{CreateSSLKeystores.txt,generate_keystores.*}

	confinto keystore
	doconf ${keystore}/*
	cd ${S}

	# Install SOLR if USEd

	if use solr; then
		cd ${SOLR_WD}

		insinto ${SOLR_DIR}
		doins apache-solr-1.4.1.war

		insinto ${SOLR_DIR}/lib
		doins lib/*.jar

		confinto Catalina/localhost
		newconf context.xml solr.xml
		dosym ${TOMCAT_CONF}/Catalina/localhost/solr.xml ${TOMCAT_CONF}/solr-context.xml

		confinto keystore
		doconf workspace-SpacesStore/conf/ssl.repo.client*

		local core; for core in archive workspace; do
			local src=${core}-SpacesStore
			local dest=${SOLR_DIR}/${core}-SpacesStore
			local conf=${TOMCAT_CONF}/solr/${core}

			# remove unnecessary files
			rm ${src}/conf/ssl*
			rm -R ${src}/conf/{xslt,admin-extra.html}

			# copy configs
			confinto ${conf}
			doconf -r ${src}/conf/*

			# copy resources
			insinto ${dest}
			doins -r ${src}/alfresco{Resources,Models}

			dosym ${conf} ${dest}/conf
			dosym "../../keystore" ${conf}/keystore

			fowners -R ${TOMCAT_USER}:${TOMCAT_GROUP} ${dest}
		done

		confinto solr
		doconf ${SOLR_WD}/solr.xml
		dosym ${TOMCAT_CONF}/solr/solr.xml ${SOLR_DIR}/solr.xml

		cd ${S}
	fi

	# Make symlinks and fix perms

	dosym ${TOMCAT_CONF}/alfresco-global.properties \
		${TOMCAT_BASE}/shared/classes/alfresco-global.properties

	fowners -R ${TOMCAT_USER}:${TOMCAT_GROUP} ${TOMCAT_BASE}/shared ${DATA_DIR}
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

	local webapps=${TOMCAT_BASE}/webapps
	if [ -d ${webapps}/alfresco ] || [ -d ${webapps}/share ]; then
		ewarn
		ewarn "Unpacked WARs found in ${webapps}. If this is an upgrade,"
		ewarn "you should remove all directories here and leave just .war files."
		ewarn
	fi

	elog "Alfresco ${SLOT} requires a SQL database to run. You have to edit"
	elog "Database connection settings in '${TOMCAT_CONF}/alfresco-global.properties'"
	elog "and then create role and database for your Alfresco instance."
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
		ewarn "'${TOMCAT_CONF}/alfresco-global.properties' and modify variables"
		ewarn "in Database connection section."
	fi

	elog
    elog "Keystores in ${TOMCAT_CONF}/keystore was populated with"
    elog "default certificates provided by Alfresco, Ltd. If you are going to"
	elog "use SOLR in production environment, you should generate your own"
	elog "certificates and keystores. You can use provided script:"
	elog "    ${TOMCAT_BASE}/bin/generate_keystores.sh"
}
