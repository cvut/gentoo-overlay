# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI=4

# Maintainer notes:
# - USE flags apache2, debug and doc are not tested!

inherit eutils user

MY_PN="shibboleth"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Shibboleth is a federated web authentication and attribute exchange system based on SAML developed by Internet2 and MACE."
HOMEPAGE="http://shibboleth.internet2.edu/"
SRC_URI="http://shibboleth.net/downloads/service-provider/${PV}/${P}.tar.gz"

LICENSE="Apache 2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="apache2 debug doc +fastcgi"

RESTRICT="mirror"

DEPEND="
	>=dev-libs/log4shib-1.0.0
	>=dev-libs/xerces-c-3.0
	>=dev-libs/xml-security-c-1.5.0
	>=dev-libs/xmltooling-c-1.4.2
	>=dev-libs/opensaml-2.4.3
	fastcgi? ( dev-libs/fcgi )
	apache2? ( >=www-servers/apache-2.2 )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"


pkg_setup() {
	enewgroup "shibd"
	enewuser "shibd" -1 -1 -1 "shibd"
}

src_prepare() {
	if ! use apache2; then
		# disable auto-enabling apache support
		sed -i 's|^need_default=yes|need_default=no|' configure \
			|| die "failed to patch configure"
	fi
}

src_configure() {
	econf \
		$(use_enable apache2 apache-22) \
		$(use_enable debug) \
		$(use_enable doc doxygen-doc) \
		$(use_with fastcgi)
}

src_install() {
	local logs="/var/log/${MY_PN}"
	local conf="/etc/shibboleth"
	local dconf="${D}/${conf}"
	local apache_mods="/etc/apache2/modules.d"
	local apache_logs="/var/log/apache2"

	emake DESTDIR="${D}" install

	## Prepare dirs ##

	if use apache2; then
		diropts -m755 -o apache -g apache
		dodir "${apache_mods}" "${apache_logs}/shibboleth"
	fi

	diropts -m750
	keepdir "${logs}"
	dodir "${conf}"/certs

	diropts -m755
	dodir "${conf}"/templates

	## Fix logs location ##

	sed -i \
		-e "s|/var/lib/log/shibboleth/|${logs}/|g" \
		-e "s|/var/lib/log/httpd/|/var/log/apache2/shibboleth/|g" \
		${D}/etc/shibboleth/*.logger \
		|| die "failed to patch *.logger"

	## Clean mess ##

	rm -R ${D}/var/lib
	rm "${dconf}"/*.dist
	rm "${dconf}"/shibd-{debian,osx.plist,redhat,suse}
	rm "${dconf}"/{upgrade.xsl,console.logger,apache.config,apache2.config}

	if use apache2; then
		mv "${dconf}"/apache22.config "${D}/${apache_mods}"/20_mod_shib.conf
	else
		rm "${dconf}"/native.logger
	fi

	mv "${dconf}"/*.html "${dconf}/templates"
	ln -s "${dconf}"/templates/{binding,discovery}Template.html "${dconf}"
	ln -s "${dconf}"/templates/partialLogout.html "${dconf}"

	mv "${dconf}"/sp-{cert,key}.pem "${dconf}/certs"
	mv "${dconf}"/keygen.sh "${dconf}/certs"


	# override provided config file with ours
	insinto ${conf}
	doins "${FILESDIR}"/shibboleth2.xml

	# fix permissions
	fowners -R shibd:shibd "${logs}" "${conf}/certs"

	# install init script
	newinitd "${FILESDIR}"/shibd.init shibd
}

pkg_postinst() {
	if use apache2; then
		# apache should be in the shibd group to be able to use shibd's socket
		einfo "adding apache to shibd group"
		usermod -a -G shibd apache
	fi

	elog "Configuration is prepared for the TestShib Two Identity Provider"
	elog "which you can use to test your Service Provider. You have to just"
	elog "configure your web server, change entityID in"
	elog "/etc/shibboleth/shibboleth2.xml to some unique identifier of yours"
	elog "and then go to https://www.testshib.org/metadata.html for the next"
	elog "instructions."
	elog ""

	if use fastcgi; then
		elog "See https://gist.github.com/4189334 for hint how to configure with Lighttpd"
		elog "via FastCGI."
	fi
}
