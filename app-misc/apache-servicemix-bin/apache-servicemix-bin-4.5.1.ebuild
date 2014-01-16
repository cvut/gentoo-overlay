# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils user

MY_PN=apache-servicemix
MY_P=${MY_PN}-${PV}

DESCRIPTION="An open-source integration container"
HOMEPAGE="http://servicemix.apache.org/"
SRC_URI="http://archive.apache.org/dist/servicemix/servicemix-4/${PV}/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="4"
KEYWORDS="amd64 ~x86"
IUSE="examples"

DEPEND="
	>=dev-java/maven-bin-2.2.1
	virtual/jre:1.6"
RDEPEND="
	virtual/jdk:1.6"

S="${WORKDIR}/${MY_P}"

MY_USER=smix
MY_NAME=${MY_PN}-${SLOT}

DEST_DIR="/opt/${MY_NAME}"
CONF_DIR="/etc/${MY_NAME}"
TEMP_DIR="/var/tmp/${MY_NAME}"
LOG_DIR="/var/log/${MY_NAME}"

pkg_setup() {
    enewgroup ${MY_USER}
    enewuser ${MY_USER} -1 /bin/sh ${DEST_DIR} ${MY_USER}
}

src_install() {
	local dest=${DEST_DIR}

	dodir ${dest}/{deploy,system,data,bin}
	keepdir ${TEMP_DIR}

	# copying is slow, make hardlinks instead
	cp -rl system/* ${D}${dest}/system || die "failed to copy system"

	insinto ${dest}
	doins -r lib

	use examples && doins -r examples

	insinto ${CONF_DIR}
	doins etc/*
	dosym ${CONF_DIR} ${dest}/etc

	exeinto /usr/local/bin
	doexe ${FILESDIR}/smxconsole
	dosym /usr/local/bin/smxconsole ${dest}/bin/smxconsole

	keepdir ${LOG_DIR}
	dosym ${LOG_DIR} ${dest}/data/log

	# fix permissions
	fowners -R ${MY_USER}:${MY_GROUP} ${dest} ${LOG_DIR} ${CONF_DIR} ${TEMP_DIR}
	fperms 600 ${CONF_DIR}/users.properties

	# RC script
	local path; for path in ${FILESDIR}/servicemix.*; do
		cp ${path} ${T} || die "failed to copy ${path}"
		local tfile=${T}/$(basename ${path})
		sed -i \
			-e "s|@KARAF_HOME@|${DEST_DIR}|" \
			-e "s|@KARAF_TEMP@|${TEMP_DIR}|" \
			-e "s|@USER@|${MY_USER}|" \
			-e "s|@SLOT@|${SLOT}|" \
			${tfile} \
			|| die "failed to filter $(basename ${path})"
	done

	newinitd ${T}/servicemix.init ${MY_NAME}
	newconfd ${T}/servicemix.conf ${MY_NAME}
}

pkg_postinst() {
	ewarn "Do not forgot to change ServiceMix's admin password in"
	ewarn "${CONF_DIR}/users.properties in production environment!"
}
