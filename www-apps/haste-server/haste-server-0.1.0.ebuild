# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

# Mainteiner notes:
# - This ebuild uses npm (Node Packaged Modules) to download and install all
#   dependencies into isolated directory inside application. That's not Gentoo
#   way how it should be done, but there's no support for Node.js packages on
#   Gentoo yet.
#

EGIT_REPO_URI="https://github.com/seejohnrun/haste-server.git"
EGIT_COMMIT="cd4c7aeab8bffa9b0d303d68085301e4d31a3709" # 2012-12-28

inherit eutils git-2 user

DESCRIPTION="Haste is an open-source pastebin software written in node.js"
HOMEPAGE="https://github.com/seejohnrun/haste-server"

LICENSE="MIT"
SLOT=0
KEYWORDS="~amd64 ~x86"
IUSE="+redis"

DEPEND="
	net-libs/nodejs
	net-misc/curl"
RDEPEND="${DEPEND}
	redis? ( dev-db/redis )"

MERGE_TYPE="binary"

MY_USER="haste"
DEST_DIR="/opt/${PN}"

pkg_setup() {
    enewgroup ${MY_USER}
    enewuser ${MY_USER} -1 /bin/bash ${DEST_DIR} ${MY_USER}
}

src_install() {
	local dest=${DEST_DIR}
	local conf=/etc/${PN}
	local logs=/var/log/${PN}
	local temp=/var/tmp/${PN}

	## Prepare directories ##

	diropts -m750
	keepdir ${logs}
	dodir ${temp}

	diropts -m755
	keepdir ${conf}
	dodir ${dest}

	## Install ##

	insinto ${conf}
	doins config.js

	insinto ${dest}
	doins -r lib spec static package.json server.js about.md

	## Install dependencies via npm ##

	cd ${D}/${dest}

	einfo "Running npm install ..."
	npm install || die "npm failed"

	if use redis; then
		npm install redis || die "npm failed"
	fi

	cd ${S}

	## Finish ##

	# fix permissions, make symlinks...
	fowners -R ${MY_USER}:${MY_USER} ${dest} ${conf} ${logs} ${temp}
	dosym ${conf}/config.js ${dest}/config.js
	dosym ${temp} ${dest}/tmp

	# install logrotate config
	dodir /etc/logrotate.d
	sed -e "s|@LOG_DIR@|${logs}|" \
		${FILESDIR}/${PN}.logrotate > ${D}/etc/logrotate.d/${PN} \
		|| die "failed to filter haste-server.logrotate"

	## RC scripts ##

	local rcscript=${PN}.init
	cp ${FILESDIR}/${rcscript} ${T} || die
	sed -i \
		-e "s|@USER@|${MY_USER}|" \
		-e "s|@GROUP@|${MY_USER}|" \
		-e "s|@HOME_DIR@|${dest}|" \
		-e "s|@LOG_DIR@|${logs}|" \
		${T}/${rcscript} \
		|| die "failed to filter ${rcscript}"

	newinitd ${T}/${rcscript} ${PN}
}
