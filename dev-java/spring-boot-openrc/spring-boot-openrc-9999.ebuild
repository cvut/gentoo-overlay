# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

EGIT_REPO_URI="https://github.com/jirutka/spring-boot-openrc.git"

inherit git-2

DESCRIPTION="OpenRC runscript for Java applications based on Spring Boot."
HOMEPAGE="https://github.com/jirutka/spring-boot-openrc"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="net-misc/socat sys-apps/openrc"

S="${WORKDIR}/${MY_P}"

src_install() {
	DESTDIR="${D}" ./install
}
