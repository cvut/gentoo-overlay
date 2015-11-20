# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

# Maintainer notes:
# - This ebuild supports Tomcat only for now.

inherit eutils java-utils-2 tomcat

MY_PN="xwiki-enterprise"
MY_PV="${PV/_pre/-milestone-}"
MY_P="${MY_PN}-web-${MY_PV}"

DESCRIPTION="Professional wiki that has powerful extensibility features such 
			as scripting in pages, plugins and a highly modular architecture."
HOMEPAGE="http://www.xwiki.org/"
SRC_URI="http://download.forge.objectweb.org/xwiki/${MY_P}.war"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="+jndi +postgres +tomcat short-urls"
REQUIRED_USE="tomcat" # see notes

DEPEND=""
RDEPEND="postgres? ( dev-java/jdbc-postgresql )"

MERGE_TYPE="binary"

S="${WORKDIR}/${MY_P}"

TOMCAT_INSTANCE="xwiki"
TOMCAT_USER="xwiki"

src_unpack() {
	unzip -q -d ${S} ${DISTDIR}/${MY_P}.war || "failed to unpack WAR"
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-4.5.3-log_to_file.patch"
	use jndi && epatch "${FILESDIR}/${PN}-5.2_pre2-use-jndi.patch"
	use short-urls && epatch "${FILESDIR}/${PN}-4.5.3-short_urls.patch"

	sed -i \
		-e "s|^[# ]*\(environment.permanentDirectory=\).*|\1${TOMCAT_BASE}/data|" \
		WEB-INF/xwiki.properties || die "failed to filter xwiki.properties"

	local randpw1=$(echo ${RANDOM}|md5sum|cut -c 1-32)
	local randpw2=$(echo ${RANDOM}|md5sum|cut -c 1-32)
	sed -i \
		-e "s|^[# ]*\(xwiki.authentication.validationKey=\).*|\1${randpw1}|" \
		-e "s|^[# ]*\(xwiki.authentication.encryptionKey=\).*|\1${randpw2}|" \
		WEB-INF/xwiki.cfg || die "failed to filter xwiki.cfg"
	
	# fix problem with cookie validation mismatch when behind proxy
	sed -i \
		-e "/xwiki.authentication.unauthorized_code/ a\ \
		\n#-# Disable binding cookie to remote IP address (which does not work properly with proxy)\
		\nxwiki.authentication.useip=false" \
		WEB-INF/xwiki.cfg || die "failed to filter xwiki.cfg"
	
	if use short-urls; then
		sed -i \
			-e "s|^[# ]*\(xwiki.defaultservletpath=\).*|\1|" \
			-e "s|^[# ]*\(xwiki.showviewaction\)=.*|\1=0|" \
			WEB-INF/xwiki.cfg || die "failed to filter xwiki.cfg"

		sed -i \
			-e "s|^[# ]*\(url.standard.getEntityPathPrefix=\).*|\1|" \
			WEB-INF/xwiki.properties || die "failed to filter xwiki.properties"
	fi
}

src_install() {
	# prepare directories and configs for Tomcat
	tomcat_prepare

	diropts -m750 -o ${TOMCAT_USER} -g ${TOMCAT_GROUP}
	dodir ${TOMCAT_BASE}/data

	# move config files to /etc/xwiki
	doconf WEB-INF/{xwiki.cfg,xwiki.properties,hibernate.cfg.xml}
	rm WEB-INF/{xwiki.cfg,xwiki.properties,hibernate.cfg.xml}

	# copy context config with or without JNDI DataSource
	use jndi && local suffix="-jndi"
	confinto Catalina/localhost
	newconf ${FILESDIR}/context${suffix}.xml ROOT.xml

	# deploy to URI /
	newwar . ROOT

	# make symlinks for configs
	local webinf="${TOMCAT_WEBAPPS}/ROOT/WEB-INF"
	dosym ${TOMCAT_CONF}/xwiki.cfg ${webinf}/xwiki.cfg
	dosym ${TOMCAT_CONF}/xwiki.properties ${webinf}/xwiki.properties
	dosym ${TOMCAT_CONF}/hibernate.cfg.xml ${webinf}/hibernate.cfg.xml
	dosym ${TOMCAT_CONF}/Catalina/localhost/ROOT.xml ${TOMCAT_CONF}/xwiki-context.xml

	if use postgres; then
		local jdbc_jar="jdbc-postgresql"
	fi
	# add JDBC driver to classpath
	cp ${FILESDIR}/xwiki.init ${T}
	sed -i \
		-e "s|\(tomcat_extra_jars=\).*|\1\"${jdbc_jar}\"|" \
		${T}/xwiki.init || die "failed to filter xwiki.init"

	# install rc files
	tomcat_doinitd ${T}/xwiki.init
	tomcat_doconfd xwiki.conf
}

pkg_postinst() {
	tomcat_pkg_postinst
	elog
	elog "XWiki Enterprise requires a SQL database to run. You have to edit"

	if use jndi; then
		elog "JDBC Data Source settings in '${TOMCAT_CONF}/xwiki-context.xml' and then"
	else
		elog "database settings in '${TOMCAT_CONF}/hibernate.cfg.xml' and then"
	fi
	elog "create role and database for your XWiki instance."
	elog

	if use postgres; then
		elog "If you have local PostgreSQL running, you can just copy&run:"
		elog "    su postgres"
		elog "    psql -c \"CREATE ROLE xwiki PASSWORD 'xwiki' \\"
		elog "        NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;\""
		elog "    createdb -E UTF-8 -O xwiki xwiki"
		elog "Note: You should change your password to something more random..."
	else
		ewarn "Since you have not set any database USE flag, you need to install" 
		ewarn "an appropriate JDBC driver and add it to tomcat_extra_jars in"
		ewarn "'/etc/init.d/${TOMCAT_INSTANCE}'. Then you must edit" 
		ewarn "'${CONF_DIR}/hibernate.cfg.xml'"
		if use jndi; then
			ewarn "and '${CONF_DIR}/xwiki-context.xml' as well."
		fi
	fi

	if use short-urls; then
		ewarn
		ewarn "Read http://platform.xwiki.org/xwiki/bin/view/Main/ShortURLs for"
		ewarn "how to setup proxy to serve static content. With ShortURLs patch"
		ewarn "Tomcat will not serve static content anymore!"
	fi

	elog
	elog "If this is a new installation then use login 'Admin' with"
	elog "password 'admin' to login into your fresh XWiki." 
}
