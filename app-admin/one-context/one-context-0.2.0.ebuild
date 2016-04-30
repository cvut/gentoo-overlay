# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="OpenNebula contextualization scripts."
HOMEPAGE="https://github.com/jirutka/one-context"
SRC_URI="https://github.com/jirutka/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""
CONFIG_CHECK="~ATA_PIIX ~ISO9660_FS"

src_install() {
	PREFIX="/usr" DESTDIR="${D}" ./install
}
