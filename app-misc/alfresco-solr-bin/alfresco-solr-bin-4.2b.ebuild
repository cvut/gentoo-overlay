# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
#
# Author: Jakub Jirutka <jakub@jirutka.cz>
#

EAPI="4"

inherit eutils user

MY_PV="${PV%?}.${PV: -1}"  # ex. 4.2b -> 4.2.b
MY_P="alfresco-community-solr-${MY_PV}"
MY_PN="alfresco-solr"
SOLR_PV="1.4.1"

DESCRIPTION="SOLR index tracking application for Alfresco CMS"
HOMEPAGE="http://alfresco.com/"
SRC_URI="mirror://sourceforge/alfresco/${MY_P}.zip"

LICENSE="LGPL-3 Apache-2.0"
SLOT="4.2"
KEYWORDS="~x86 ~amd64"
IUSE=""

TOMCAT_SLOT="7"

DEPEND="
	app-arch/unzip
	virtual/jre
	>=www-servers/tomcat-7.0.29"
RDEPEND="
	>=virtual/jdk-1.6"

S="${WORKDIR}"

MY_NAME="${MY_PN}-${SLOT}"
MY_USER="alfresco"
MY_GROUP="alfresco"

TOMCAT_HOME="/usr/share/tomcat-${TOMCAT_SLOT}"
DEST_DIR="/opt/${MY_NAME}"
CONF_DIR="/etc/${MY_NAME}"

pkg_setup() {
	ebegin "Creating alfresco user and group"
    enewgroup ${MY_GROUP} \
		|| die "Unable to create ${MY_GROUP} group"
    enewuser ${MY_USER} -1 /bin/sh "/opt/${MY_NAME}" ${MY_GROUP} \
		|| die "Unable to create ${MY_USER} user"
}

src_prepare() {
    # fix permissions
    chmod -R a-x,a+X *

	# expand WAR
	mkdir war; cd war
	jar xf ../"apache-solr-${SOLR_PV}.war"
	cd "${WORKDIR}"
}

src_install() {
	local conf="${CONF_DIR}"
	local dest="${DEST_DIR}"
	local tomcat="${dest}/server"
	local logs="/var/log/${MY_NAME}"
	local temp="/var/tmp/${MY_NAME}"
	local data="${dest}/data"

	local user="${MY_USER}"
	local group="${MY_GROUP}"



	### Prepare directories ###

	diropts -m700
	keepdir "${data}"
	dodir "${temp}"

	diropts -m750
	dodir "${conf}"/Catalina/localhost
	dodir "${tomcat}"/work

	diropts -m755
	keepdir "${conf}" "${logs}"

	insopts -m644
	insinto "${conf}"


	### Install Tomcat instance ###

	## filter and install tomcat-logging.properties ##

	local tfile="tomcat-logging.properties"

	cp "${FILESDIR}/${tfile}" "${T}" || die
	sed -i \
		-e "s|@LOG_DIR@|${logs}|" "${T}/${tfile}" \
		|| die "failed to filter ${tfile}"

	doins "${T}/${tfile}"

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

	## filter and install solr-context.xml ##

	local tfile="solr-context.xml"

	cp "${FILESDIR}/${tfile}" "${T}" || die
	sed -i \
		-e "s|@SOLR_HOME@|${dest}|" \
		"${T}/${tfile}" \
		|| die "failed to filter ${tfile}"

	insinto "${conf}"/Catalina/localhost
	newins "${T}/${tfile}" solr.xml
	dosym "${conf}"/Catalina/localhost/solr.xml "${conf}"/solr-context.xml

	## install tomcat-users.xml ##

	insinto "${conf}"
	doins "${FILESDIR}"/tomcat-users.xml

	## make symlinks ##

	dosym "${TOMCAT_HOME}"/conf/web.xml "${conf}"/web.xml
	dosym "${conf}" "${tomcat}"/conf
	dosym "${logs}" "${tomcat}"/logs


	### Install Solr ###

	# copy lib
	insinto "${dest}"/lib
	doins lib/*.jar

	# copy keystores
	insinto "${conf}"/keystore
	doins workspace-SpacesStore/conf/ssl*
	doins alf_data/keystore/ssl.{key,trust}store

	# filter and copy SpacesStores
	local core; for core in archive workspace; do
		local _src="${core}-SpacesStore"
		local _dest="${dest}/${core}-SpacesStore"
		local _conf="${conf}/${core}"
		local cron="0 0/1 * * * ? *"

		# add prefix for keystore path and set more reasonable cron timer
		sed -i \
			-e "s|@@ALFRESCO_SOLR_DIR@@|${data}|" \
			-e "s|\(store.location=\)\(.*\)|\1keystore/\2|" \
			-e "s|\(passwordFileLocation=\)\(.*\)|\1keystore/\2|" \
			-e "s|\(alfresco.cron=\).*|\1${cron}|" \
			"$_src"/conf/solrcore.properties \
			|| die "failed to filter solrcore.properties"

		# remove keystores (moved to single location)
		rm "$_src"/conf/ssl*

		# copy configs
		insinto "$_conf"
		doins -r "$_src"/conf/*

		# copy resources
		insinto "$_dest"
		doins -r "$_src"/alfrescoResources

		dosym "$_conf" "$_dest/conf"
		dosym "../keystore" "$_conf/keystore"
	done

	# copy solr.xml
	insinto "${conf}"
	doins "${FILESDIR}"/solr.xml
	dosym "${conf}"/solr.xml "${dest}"

	## deploy WAR ##

	# fix log location
	local key='log4j.appender.File.File'
	local prefix='${catalina.base}/logs/'
	sed -i \
		-e "s|\(${key}=\)\(.*/\)\?\([\w\.]*\)|\1${prefix}\3|" \
		war/WEB-INF/classes/log4j.properties \
		|| die "failed to modify log4j.properties"

	insinto "${tomcat}"/webapps/solr
	doins -r war/*


	### Fix permissions ####

	fowners -R ${user}:${group} "${dest}" "${conf}" "${temp}" "${logs}"

	fperms 640 "${conf}"/{server.xml,tomcat-users.xml}
	fperms 640 "${conf}"/Catalina/localhost/solr.xml
	fperms 600 "${conf}"/keystore/ssl-{key,trust}store-passwords.properties


	### RC scripts ###

	cp "${FILESDIR}"/alfresco-solr-tc.conf "${T}" || die
	local tfile="${T}"/alfresco-solr-tc.conf

	local path; for path in "${FILESDIR}"/alfresco-solr-tc.*; do
		cp "${path}" "${T}" || die
		local tfile="${T}"/`basename ${path}`
		sed -i \
			-e "s|@CATALINA_HOME@|${TOMCAT_HOME}|" \
			-e "s|@CATALINA_BASE@|${tomcat}|" \
			-e "s|@EXTRA_JARS@||" \
			-e "s|@TEMP_DIR@|${temp}|" \
			-e "s|@CONF_DIR@|${conf}|" \
			-e "s|@USER@|${user}|" \
			-e "s|@GROUP@|${group}|" \
			-e "s|@NAME@|SOLR/Alfresco ${SLOT}|" \
			"${tfile}" \
			|| die "failed to filter `basename ${path}`"
	done

	newinitd "${T}"/alfresco-solr-tc.init "${MY_NAME}"
	newconfd "${T}"/alfresco-solr-tc.conf "${MY_NAME}"
}

pkg_postinst() {
	elog "Keystores in ${CONF_DIR}/keystore was populated with"
	elog "default certificates provided by Alfresco, Ltd. In production"
	elog "environment you should generate your own certificates and keystores."
	elog "Use script generate_keystores.sh provided with alfresco-bin package."
}
