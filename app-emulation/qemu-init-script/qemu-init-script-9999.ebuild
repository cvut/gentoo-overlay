# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

EGIT_REPO_URI="https://github.com/jirutka/qemu-openrc.git"

inherit git-2

DESCRIPTION="OpenRC runscript for QEMU/KVM."
HOMEPAGE="https://github.com/jirutka/qemu-openrc"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="app-emulation/qemu net-misc/socat sys-apps/openrc"
CONFIG_CHECK="
	~HW_RANDOM_VIRTIO
	~SCSI_VIRTIO
	~VIRTIO
	~VIRTIO_BALLOON
	~VIRTIO_NET
	~VIRTIO_PCI"

src_install() {
	PREFIX="/usr" DESTDIR="${D}" ./install
}
