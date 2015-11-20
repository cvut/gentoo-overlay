# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4

# Maintainer notes:
# - USE flags debug, doc and static-libs are not tested!

inherit eutils

MY_PN="xmltooling"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A lower-level library that provides a higher level interface to XML processing, particularly in light of signing and encryption."
HOMEPAGE="http://shibboleth.internet2.edu/"
SRC_URI="http://shibboleth.net/downloads/c++-opensaml/2.4.3/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc static-libs"

RESTRICT="mirror"

RDEPEND="
	>=dev-libs/log4shib-1.0.0
	>=dev-libs/xerces-c-3.0
	>=dev-libs/xml-security-c-1.5.0
	dev-libs/openssl
	net-misc/curl"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	# do not mess pkgconfig/xmltooling.pc:Libs with LDFLAGS
	# see #382737 (it's for another package but the same issue)
	sed -i -e '/Libs:/s:@LDFLAGS@ ::' configure \
		|| die "failed to patch configure"
}

src_configure() {
	econf \
		$(use_enable debug) \
		$(use_enable doc doxygen-doc) \
		$(use_enable static-libs static)
}
