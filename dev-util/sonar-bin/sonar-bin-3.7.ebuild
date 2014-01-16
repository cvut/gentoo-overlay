# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

MY_PV="${PV/_alpha/M}"
MY_PV="${MY_PV/_rc/-RC}"
MY_PN="sonar"
MY_P="${MY_PN}-${MY_PV}"

inherit eutils user

DESCRIPTION="Sonar is an open platform to manage code quality."
HOMEPAGE="http://sonarsource.org/"
SRC_URI="http://dist.sonar.codehaus.org/${MY_P}.zip"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE=""
RESTRICT="mirror"

DEPEND="app-arch/unzip"
RDEPEND=">=virtual/jdk-1.5"

MERGE_TYPE="binary"

S="${WORKDIR}/${MY_P}"

DEST_DIR="/opt/${MY_PN}"
CLIB_DIR="${DEST_DIR}/clib"
CONF_DIR="/etc/${MY_PN}"
LOGS_DIR="/var/log/${MY_PN}"
TEMP_DIR="/var/tmp/${MY_PN}"
OWNERS="${MY_PN}:${MY_PN}"

pkg_setup() {
    enewgroup ${MY_PN}
    enewuser ${MY_PN} -1 /bin/sh ${DEST_DIR} ${MY_PN}
}

src_prepare() {
    # fix permissions
    chmod -R a-x,a+X conf data extensions extras lib war COPYING

    # fix EOL in configuration files
    for i in conf/* ; do
        awk '{ sub("\r$", ""); print }' $i > $i.new
        mv $i.new $i
    done

	# change file locations
	sed -i \
		-e "s|^\(wrapper.java.classpath.[1-9]=\)\.\./\.\.\(.*\)|\1${DEST_DIR}\2|" \
		-e "s|^\(wrapper.java.library.path.1=\).*|\1${CLIB_DIR}|" \
		-e "s|^\(wrapper.logfile=\).*|\1${LOGS_DIR}/wrapper.log|" conf/wrapper.conf \
		|| die "Failed to change file locations in wrapper.conf"
	
	# add wrapper.syslog.ident property
	sed -i -e "/wrapper.syslog.loglevel/a \
		\\\n# Specifiy the identity field used in syslog entries \
		\nwrapper.syslog.ident=sonar" conf/wrapper.conf \
		|| die "Failed to add new property to wrapper.conf"

    # remove useless Windows config sections
	sed -i \
		-e '/Wrapper Windows Properties/N;//,/^#\*\*/d' \
		-e '/Wrapper Windows NT/N;//,/^#\*\*/d' conf/wrapper.conf \
		|| die "Failed to remove useless config sections in wrapper.conf"
	
	# change config files location
	for dir in bin/linux* ; do
		sed -i -e "s|^\(WRAPPER_CONF=\).*|\1${CONF_DIR}/wrapper.conf|" "$dir/sonar.sh" \
			|| die "Failed to change config files location in sonar.sh"
	done
	
	# change log files location
	sed -i \
		-e "/<configuration.*/a \
			\\\n  <property name=\"logs\" value=\"${LOGS_DIR}\" />" \
		-e "s|\${SONAR_HOME}/logs|\${logs}|" \
		conf/logback.xml \
		|| die "Failed to change logs file location in logback.xml"
}

src_install() {
	diropts -m755
	dodir "${DEST_DIR}" "${DEST_DIR}/war"

	# copy war directory
	# copying is slow, make hardlinks instead
	cp -rl war/sonar-server "${D}${DEST_DIR}/war/"

	# copy extensions and lib dirs
	insinto "${DEST_DIR}"
	doins -r extensions lib

	# copy wrapper bin and lib
	if use x86; then
		wrapper_bin="bin/linux-x86-32"
		wrapper_lib="${wrapper_bin}/lib"
	elif use amd64; then
		wrapper_bin="bin/linux-x86-64"
		wrapper_lib="${wrapper_bin}/lib"
	fi
	exeinto "${DEST_DIR}/bin"
	doexe "${wrapper_bin}/wrapper"
	exeinto "${CLIB_DIR}"
	doexe "${wrapper_lib}/libwrapper.so"

	# copy conf
	insinto "${CONF_DIR}"
	doins conf/*
	dosym "${CONF_DIR}" "${DEST_DIR}/conf"

	# prepare log, temp, data directories
	diropts -m750
	keepdir "${LOGS_DIR}"
	keepdir "${DEST_DIR}/data"

	diropts -m700
	keepdir "${TEMP_DIR}"
	dosym "${TEMP_DIR}" "${DEST_DIR}/temp"

	# fix permissions
	fowners -R ${OWNERS} "${DEST_DIR}"/{war/sonar-server/deploy,extensions,data}
	fowners -R ${OWNERS} "${TEMP_DIR}" "${LOGS_DIR}"

	# filter and copy init script
	cp "${FILESDIR}/sonar-r1.init" "${T}"
	tfile="${T}/sonar-r1.init"
	sed -i \
		-e "s|@DEST_DIR@|${DEST_DIR}|g" \
		-e "s|@CONF_DIR@|${CONF_DIR}|g" \
		"${tfile}" || die "Filtering sonar-r1.init failed"
	newinitd "${tfile}" ${MY_PN}
}

pkg_postinst() {
	einfo "The embedded database H2 is used by default. However, it is"
	einfo "recommended for tests only, for production environment you must" 
	einfo "use an external database like PostgreSQL.\n"
	einfo "Sonar with embedded Jetty is listening on port 9000 by default.\n"
	einfo "You can configure all these settings in:"
	einfo "    ${CONF_DIR}/sonar.properties"
	einfo
	einfo "If you're upgrading from previous version, please read upgrade guide"
	einfo "http://docs.codehaus.org/display/SONAR/Upgrading"
}
