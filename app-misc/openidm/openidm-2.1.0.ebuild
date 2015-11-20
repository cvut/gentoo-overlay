# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

inherit eutils subversion java-pkg-2 user

DESCRIPTION="Open source identity management system written in the Java."
HOMEPAGE="http://openidm.forgerock.org"
ESVN_REPO_URI="https://svn.forgerock.org/${PN}/tags/${PV}"

LICENSE="CDDL-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+mysql examples test"

DEPEND="
	>=virtual/jre-1.6
	>=dev-java/maven-bin-3
	app-arch/unzip"
RDEPEND="${DEPEND}
	>=virtual/jdk-1.6
	mysql? (
		|| ( dev-java/jdbc-mysql-bin
			 dev-java/jdbc-mysql ) )"

MY_USER="openidm"
DEST_DIR="/opt/${PN}"
CONF_DIR="/etc/${PN}"
LOGS_DIR="/var/log/${PN}"
TEMP_DIR="/var/tmp/${PN}"

emvn() {
	# TODO make simple eclass and move repo to /var/portage/distfiles
	mvn -Dmaven.repo.local="/var/tmp/portage/.mvn-repo" $@
}

pkg_setup() {
    enewgroup ${MY_USER}
    enewuser ${MY_USER} -1 /sbin/nologin ${DEST_DIR} ${MY_USER}
}

src_prepare() {
	if java-pkg_is-vm-version-ge 1.7; then
		epatch "${FILESDIR}/${PN}-2.1.0-fix-osgi-generics.patch"
	fi

	mkdir -p "${T}/files"

	sed -e "s|@HOME@|${DEST_DIR}|" \
		${FILESDIR}/openidm-cli > ${T}/files/openidm-cli \
		|| die "failed to filter openidm-cli"

	sed -e "s|@USER@|${MY_USER}|" \
		-e "s|@HOME@|${DEST_DIR}|" \
		-e "s|@TEMP@|${TEMP_DIR}|" \
		-e "s|@PIDFILE@|/run/${PN}.pid|" \
		${FILESDIR}/${PN}.init > ${T}/files/${PN}.init \
		|| die "failed to filter ${PN}.init"
}

src_compile() {
	use test || local mvn_args="-DskipTests=true"

	einfo "Building with Maven ..."
	emvn install ${mvn_args} || die "build failed"
}

src_install() {
	unzip ${S}/openidm-zip/target/${P}.zip || die "failed to unzip ${P}.zip"
	cd ${PN} || die "cd ${PN} failed"

	# Prepare

	if use mysql; then
		rm conf/repo.orientdb.json
		cp samples/misc/repo.jdbc.json conf || die
	else
		cp samples/misc/repo.jdbc.json conf/repo.jdbc.json.example
	fi

	sed -i \
		-e "s|logs/openidm.log|${LOGS_DIR}/openidm.log|" \
		conf/logging-config.xml || die "failed to filter logging-config.xml"

	sed -i \
		-e "s|logs/openidm%u.log|${LOGS_DIR}/openidm%u.log|" \
		conf/logging.properties || die "failed to filter logging.properties"

	dodir ${DEST_DIR} ${CONF_DIR} ${LOGS_DIR} ${TEMP_DIR}
	dodir ${DEST_DIR}/{audit,felix-cache}

	# Install

	insinto ${DEST_DIR}
	doins -r ./{bundle,connectors}

	# doins is slow, make hardlinks instead
	cp -rl ui "${D}/${DEST_DIR}/" || die "failed to copy ./ui"

	use examples && dodoc -r samples

	insinto ${DEST_DIR}/bin
	doins bin/*.jar
	doins bin/launcher.json
	doins -r bin/defaults

	insinto ${CONF_DIR}
	doins -r conf/*
	doins -r ./{script,security}

	dobin ${T}/files/openidm-cli

	dosym ${CONF_DIR} ${DEST_DIR}/conf
	dosym ${CONF_DIR}/script ${DEST_DIR}/script
	dosym ${CONF_DIR}/security ${DEST_DIR}/security

	insinto ${DEST_DIR}/db
	if use mysql; then
		doins -r db/scripts/mysql

		local jdbc_path=$(java-config --classpath 'jdbc-mysql*')
		if [ -r "${jdbc_path}" ]; then
			dosym ${jdbc_path} ${DEST_DIR}/bundle/jdbc-mysql.jar \
				|| die "failed to create symlink for ${jdbc_path}"
		else
			ewarn "Failed to locate jdbc-mysql JAR file via java-config!"
			ewarn "Installation will continue, but to use MySQL you must manually copy or link"
			ewarn "MySQL JDBC driver into ${DEST_DIR}/bundle."
		fi
	else
		doins -r db/*
	fi

	# fix permissions
	fowners -R ${MY_USER}:${MY_USER} ${CONF_DIR} ${LOGS_DIR} ${TEMP_DIR} \
		${DEST_DIR}/{audit,felix-cache}
	fperms 750 ${DEST_DIR}/{audit,felix-cache} ${CONF_DIR}/security

	# fperms doesn't support wildcard, so...
	chmod 640 "${D}"/${CONF_DIR}/repo.jdbc.json* 2>/dev/null

	newinitd ${T}/files/${PN}.init ${PN}
	newconfd ${FILESDIR}/${PN}.conf ${PN}
}

pkg_postinst() {
	if use mysql; then
		elog "OpenIDM requires a SQL database to run. You have to edit connection"
		elog "settings in '${CONF_DIR}/repo.jdbc.json' and create role and database"
		elog "for your OpenIDM instance."
		elog "Then import the DDL script '${DEST_DIR}/db/mysql/openidm.sql'"
		elog
	else
		ewarn "Since you have not set any database USE flag, the in-memory database OrientDB"
		ewarn "will be used. THIS IS FOR TESTING ONLY AND SHOULD NOT BE USED IN PRODUCTION!"
		ewarn
		ewarn "You should install a JDBC driver for your database and copy or link it into"
		ewarn "'${DEST_DIR}/bundle'. Then in '${CONF_DIR}' remove 'repo.orientdb.json',"
		ewarn "rename 'repo.jdbc.json.example' -> 'repo.jdbc.json' and edit connection"
		ewarn "settings. Finally import an appropriate DDL script from ${DEST_DIR}/db."
		ewarn
	fi
}
