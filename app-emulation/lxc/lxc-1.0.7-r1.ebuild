# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

MY_P="${P/_/-}"
PYTHON_COMPAT=( python{3_3,3_4} )
DISTUTILS_OPTIONAL=1

inherit autotools bash-completion-r1 distutils-r1 eutils linux-info versionator flag-o-matic

DESCRIPTION="LinuX Containers userspace utilities"
HOMEPAGE="https://linuxcontainers.org/"
SRC_URI="https://github.com/lxc/lxc/archive/${MY_P}.tar.gz"

KEYWORDS="amd64 ~arm ~arm64 ~ppc64 x86"

LICENSE="LGPL-3"
SLOT="0"
IUSE="doc examples lua python seccomp"

RDEPEND="net-libs/gnutls
	sys-libs/libcap
	lua? ( >=dev-lang/lua-5.1:= )
	python? ( ${PYTHON_DEPS} )
	seccomp? ( sys-libs/libseccomp )"

DEPEND="${RDEPEND}
	doc? ( app-text/docbook-sgml-utils )
	>=sys-kernel/linux-headers-3.2"

RDEPEND="${RDEPEND}
	sys-apps/util-linux
	app-misc/pax-utils
	virtual/awk"

CONFIG_CHECK="~CGROUPS ~CGROUP_DEVICE
	~CPUSETS ~CGROUP_CPUACCT
	~CGROUP_SCHED

	~NAMESPACES
	~IPC_NS ~USER_NS ~PID_NS

	~DEVPTS_MULTIPLE_INSTANCES
	~CGROUP_FREEZER
	~UTS_NS ~NET_NS
	~VETH ~MACVLAN

	~POSIX_MQUEUE
	~!NETPRIO_CGROUP

	~!GRKERNSEC_CHROOT_MOUNT
	~!GRKERNSEC_CHROOT_DOUBLE
	~!GRKERNSEC_CHROOT_PIVOT
	~!GRKERNSEC_CHROOT_CHMOD
	~!GRKERNSEC_CHROOT_CAPS
"

ERROR_DEVPTS_MULTIPLE_INSTANCES="CONFIG_DEVPTS_MULTIPLE_INSTANCES:	needed for pts inside container"

ERROR_CGROUP_FREEZER="CONFIG_CGROUP_FREEZER:	needed to freeze containers"

ERROR_UTS_NS="CONFIG_UTS_NS:	needed to unshare hostnames and uname info"
ERROR_NET_NS="CONFIG_NET_NS:	needed for unshared network"

ERROR_VETH="CONFIG_VETH:	needed for internal (host-to-container) networking"
ERROR_MACVLAN="CONFIG_MACVLAN:	needed for internal (inter-container) networking"

ERROR_POSIX_MQUEUE="CONFIG_POSIX_MQUEUE:	needed for lxc-execute command"

ERROR_NETPRIO_CGROUP="CONFIG_NETPRIO_CGROUP:	as of kernel 3.3 and lxc 0.8.0_rc1 this causes LXCs to fail booting."

ERROR_GRKERNSEC_CHROOT_MOUNT=":CONFIG_GRKERNSEC_CHROOT_MOUNT	some GRSEC features make LXC unusable see postinst notes"
ERROR_GRKERNSEC_CHROOT_DOUBLE=":CONFIG_GRKERNSEC_CHROOT_DOUBLE	some GRSEC features make LXC unusable see postinst notes"
ERROR_GRKERNSEC_CHROOT_PIVOT=":CONFIG_GRKERNSEC_CHROOT_PIVOT	some GRSEC features make LXC unusable see postinst notes"
ERROR_GRKERNSEC_CHROOT_CHMOD=":CONFIG_GRKERNSEC_CHROOT_CHMOD	some GRSEC features make LXC unusable see postinst notes"
ERROR_GRKERNSEC_CHROOT_CAPS=":CONFIG_GRKERNSEC_CHROOT_CAPS	some GRSEC features make LXC unusable see postinst notes"

DOCS=(AUTHORS CONTRIBUTING MAINTAINERS NEWS README doc/FAQ.txt)

S="${WORKDIR}/${PN}-${MY_P}"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

src_prepare() {
	sed -i 's/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/g' configure.ac || die
	if [[ -n ${BACKPORTS} ]]; then
		epatch "${WORKDIR}"/patches/*
	fi

	epatch "${FILESDIR}"/${PN}-1.0.6-bash-completion.patch

	eautoreconf
}

src_configure() {
	append-flags -fno-strict-aliasing

	if use python; then
		#541932
		python_setup "python3*"
		export PKG_CONFIG_PATH="${T}/${EPYTHON}/pkgconfig:${PKG_CONFIG_PATH}"
	fi

	econf \
		--localstatedir=/var \
		--bindir=/usr/bin \
		--sbindir=/usr/bin \
		--docdir=/usr/share/doc/${PF} \
		--with-config-path=/var/lib/lxc	\
		--with-rootfs-path=/var/lib/lxc/rootfs \
		--with-distro=gentoo \
		--with-runtime-path=/run \
		--disable-apparmor \
		$(use_enable doc) \
		$(use_enable examples) \
		$(use_enable lua) \
		$(use_enable python) \
		$(use_enable seccomp)
}

python_compile() {
	distutils-r1_python_compile build_ext -I ../ -L ../${PN}
}

src_compile() {
	default

	if use python; then
		pushd "${S}/src/python-${PN}" > /dev/null
		distutils-r1_src_compile
		popd > /dev/null
	fi
}

src_install() {
	default

	mv "${ED}"/usr/share/bash-completion/completions/${PN} "${ED}"/$(get_bashcompdir)/${PN}-start || die
	bashcomp_alias ${PN}-start \
		${PN}-{attach,cgroup,clone,console,create,destroy,device,execute,freeze,info,monitor,snapshot,start-ephemeral,stop,unfreeze,wait}

	if use python; then
		pushd "${S}/src/python-lxc" > /dev/null
		# Unset DOCS. This has been handled by the default target
		unset DOCS
		distutils-r1_src_install
		popd > /dev/null
	fi

	keepdir /etc/lxc /var/lib/lxc/rootfs /var/log/lxc

	find "${D}" -name '*.la' -delete

	# Gentoo-specific additions!
	# Use initd.3 per #517144
	newinitd "${FILESDIR}/${PN}.initd.3" ${PN}

	# lxc-devsetup script
	exeinto /usr/libexec/${PN}
}

pkg_postinst() {
	elog "There is an init script provided with the package now; no documentation"
	elog "is currently available though, so please check out /etc/init.d/lxc ."
	elog "You _should_ only need to symlink it to /etc/init.d/lxc.configname"
	elog "to start the container defined into /etc/lxc/configname.conf ."
	elog "For further information about LXC development see"
	elog "http://blog.flameeyes.eu/tag/lxc" # remove once proper doc is available
	elog ""
}
