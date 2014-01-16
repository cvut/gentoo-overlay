# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

# Mainteiner notes
# - Shaj binary was removed as it's not used by default and needs additional
#   JAR not bundled with OpenFire anyway. If you need it, please write ebuild 
#   for shaj library. You can use repository https://github.com/jirutka/shaj 
#   which is copied from the Atlassian's SVN. Note that shaj is very old and
#   not maintained for years!

JAVA_PKG_IUSE="doc"

inherit eutils java-pkg-2 java-ant-2 user

MY_P=${PN}_src_${PV//./_}
DESCRIPTION="Openfire (formerly wildfire) real time collaboration (RTC) server"
HOMEPAGE="http://www.igniterealtime.org/projects/openfire/"
SRC_URI="http://www.igniterealtime.org/builds/openfire/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	>=virtual/jre-1.5"
DEPEND="
	>=virtual/jdk-1.5"

S="${WORKDIR}/${PN}_src/build"

# Jikes doesn't support -source 1.5
EANT_FILTER_COMPILER="jikes"
EANT_TASKS="ant-contrib"
EANT_BUILD_TARGET="openfire plugins"

DEST_DIR="/opt/openfire"
LOGS_DIR="/var/log/openfire"
CONF_DIR="/etc/openfire"

MY_USER=jabber


pkg_setup() {
	enewgroup ${MY_USER}
	enewuser ${MY_USER} -1 -1 -1 ${MY_USER}
}

java_prepare() {
	epatch "${FILESDIR}"/buildxml-ant.patch
	# TODO should replace jars in build/lib with ones packaged by us -nichoj
}

src_install() {
	cd ../target/openfire

	# remove shaj binary (see notes above)
	rm -R resources/nativeAuth
	# remove useless files
	rm lib/*.dll

	insinto ${DEST_DIR}/lib
	doins lib/*

	insinto ${DEST_DIR}/plugins
	doins -r plugins/*

	# this contains SSH keys therefore should be between configs
	insinto ${CONF_DIR}/security
	doins -r resources/security/*
	dosym ${CONF_DIR}/security ${DEST_DIR}/resources/security

	insinto ${DEST_DIR}/resources
	rm -Rf resources/security
	doins -r resources/*

	insinto ${CONF_DIR}
	doins conf/openfire.xml
	dosym ${CONF_DIR} ${DEST_DIR}/conf

	keepdir ${LOGS_DIR}
	dosym ${LOGS_DIR} ${DEST_DIR}/logs

	if use doc; then
		dohtml -r ../../documentation/docs/*
	fi
	dodoc ../../documentation/dist/*

	exeinto ${CONF_DIR}/security
	doexe "${FILESDIR}"/keystore-import.sh

	# fix permissions
	fowners -R ${MY_USER}:${MY_USER} ${DEST_DIR} ${CONF_DIR} ${LOGS_DIR}

	# RC scripts
	local path; for path in "${FILESDIR}"/openfire.*; do
		cp ${path} ${T} || die "failed to copy ${path}"
		local tfile=${T}/$(basename ${path})
		sed -i \
			-e "s|@USER@|${MY_USER}|" \
			-e "s|@HOME@|${DEST_DIR}|" \
			${tfile} \
			|| die "failed to filter $(basename ${path})"
	done

	newinitd ${T}/openfire.init ${PN}
	newconfd ${T}/openfire.conf ${PN}
}

pkg_postinst() {
	einfo "Start OpenFire, open browser at port 9090 and follow setup guide."
}

