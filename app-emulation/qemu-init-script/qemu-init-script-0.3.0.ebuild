# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

MY_PN="qemu-openrc"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="OpenRC runscript for QEMU/KVM."
HOMEPAGE="https://github.com/jirutka/qemu-openrc"
SRC_URI="https://github.com/jirutka/${MY_PN}/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="app-emulation/qemu net-misc/socat sys-apps/openrc"
CONFIG_CHECK="
	~HW_RANDOM_VIRTIO
	~SCSI_VIRTIO
	~VIRTIO
	~VIRTIO_BALLOON
	~VIRTIO_NET
	~VIRTIO_PCI"

S="${WORKDIR}/${MY_P}"

src_install() {
	PREFIX="/usr" DESTDIR="${D}" ./install
}
