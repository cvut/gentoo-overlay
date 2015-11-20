# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

# Mainteiner notes:
# - This ebuild supports Tomcat only for now.

inherit eutils tomcat

MY_PN="artifactory"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Artifactory Maven Artifact Server"
HOMEPAGE="http://www.jfrog.com/home/v_artifactory_opensource_overview"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.zip"

LICENSE="LGPL-3"
SLOT="2"
KEYWORDS="~amd64 ~x86"

IUSE="postgres +tomcat"
REQUIRED_USE="tomcat" # see notes

DEPEND=""
RDEPEND="postgres? ( dev-java/jdbc-postgresql )"

MERGE_TYPE="binary"

S="${WORKDIR}/${MY_P}"

TOMCAT_INSTANCE="artifactory-${SLOT}"
TOMCAT_USER="artifact"

src_prepare() {
	sed -i \
		-e 's|#*\(artifactory.jcr.configDir=\).*|\1repo|' \
		etc/artifactory.system.properties \
		|| die "failed to filter artifactory.system.properties"

	if use postgres; then
		local range='/<DataSource.*>/,/<\/DataSource>/'
		sed -i \
			-e "${range} s|artifactory_user|artifactory|" \
			-e "${range} s|<!--.*validationQuery.*|<param name=\"validationQuery\" value=\"select 1\"/>|" \
			-e "${range} s|<!--.*maxPoolSize.*|<param name=\"maxPoolSize\" value=\"25\"/>|" \
			etc/repo/filesystem-postgresql/repo.xml || die "failed to filter repo.xml"
	fi
}

src_install() {
	# prepare directories and configs for Tomcat
	tomcat_prepare

	diropts -m750 -o ${TOMCAT_USER} -g ${TOMCAT_GROUP}
	dodir ${TOMCAT_BASE}/{data,backup}

	## CLI ##

	insinto ${TOMCAT_BASE}/bin/lib
	doins artifactory.jar
	doins clilib/*.jar

	local tfile="artadmin-r1"
	cp ${FILESDIR}/${tfile} ${T} || die
	sed -i \
		-e "s|@CLI_JAR@|${TOMCAT_BASE}/bin/artifactory.jar|" \
		-e "s|@LIB_DIR@|${TOMCAT_BASE}/bin/lib|" \
		${T}/${tfile} || die "failed to filter ${tfile}"
	exeinto ${TOMCAT_BASE}/bin
	newexe ${T}/${tfile} artadmin

	## Webapp ##

	doconf etc/{artifactory.config,logback,mimetypes}.xml

	confinto Catalina/localhost
	newconf ${FILESDIR}/context.xml ROOT.xml

	# deploy to URI /
	newwar webapps/artifactory.war ROOT.war

	# repository configs
	confinto repo; confopts -m640
	if use postgres; then
		local jdbc_jar="jdbc-postgresql"
		doconf etc/repo/filesystem-postgresql/repo.xml
		newconf etc/repo/filesystem-derby/repo.xml repo.xml.derby
	else
		doconf etc/repo/filesystem-derby/repo.xml
	fi

	# increase limit for number of open files
	echo "${TOMCAT_USER} hard nofile 32000" > ${T}/limits
	insinto /etc/security/limits.d
	newins ${T}/limits ${MY_PN}.conf

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
	ewarn "Cleaning ${TOMCAT_BASE}/work ..."
	rm -Rf "${TOMCAT_BASE}"/work/* 2>/dev/null

	elog "Artifactory uses SQL database to store metadata and file system"
	elog "storage for binary files. These will be stored in"
	elog "'${TOMCAT_BASE}', ensure that there is enough space."
	elog

	if use postgres; then
		elog "To use PostgreSQL as your database storage, edit DataSource settings"
		elog "in '${TOMCAT_CONF}/repo/repo.xml' and then create role and database for"
		elog "your Artifactory instance."
		elog
		elog "If you have local PostgreSQL running, you can just copy&run:"
		elog "    su postgres"
		elog "    psql -c \"CREATE ROLE ${MY_PN} PASSWORD 'password' \\"
		elog "        NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;\""
		elog "    createdb -E UTF-8 -O ${MY_PN} ${MY_PN}"
		elog "Note: You should change your password to something more random..."
	else
		elog "Derby database is already preconfigured for you. If you want to see"
		elog "config anyway, it's in '${TOMCAT_CONF}/repo/repo.xml'."
	fi

	elog
	elog "The default password for user 'admin' is 'password'."
}
