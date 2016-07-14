# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="OpenRC runscript for Java applications based on Spring Boot."
HOMEPAGE="https://github.com/jirutka/spring-boot-openrc"
SRC_URI="https://github.com/jirutka/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="net-misc/socat sys-apps/openrc"

S="${WORKDIR}/${MY_P}"

src_install() {
	DESTDIR="${D}" ./install
}
