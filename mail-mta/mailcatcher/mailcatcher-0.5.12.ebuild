# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

USE_RUBY="ruby19 ruby20"

inherit eutils ruby-ng

DESCRIPTION="Runs an SMTP server, catches and displays email in a web interface."
HOMEPAGE="http://mailcatcher.me/"
SRC_URI="https://github.com/sj26/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE=""

GEMS_DEPEND=">=dev-db/sqlite-3.6.16"
DEPEND="${GEMS_DEPEND}"
RDEPEND="${DEPEND}"
ruby_add_rdepend "
	virtual/rubygems
	>=dev-ruby/bundler-1.0"

DEST_DIR=/usr/share/${PN}

RUBY_PATCHES=(
	"${PN}-0.5.12-no-exit.patch"
	"${PN}-0.5.12-persist.patch"
)

all_ruby_prepare() {
	# Fix mailcatcher version in Gemfile.lock if wrong
	sed -i \
		-e "s/\(mailcatcher \)([0-9\.]*)/\1(${PV})/" \
		Gemfile.lock || die "failed to filter Gemfile.lock"
	
	local file; for file in ${FILESDIR}/{mailcatcher,catchmail}; do
		sed "s|@BASE_PATH@|${DEST_DIR}|" ${file} > ${T}/$(basename $file) \
			|| die "failed to filter ${file}"	
	done

	# remove useless files
	rm -R examples .git*
}

all_ruby_install() {
	# install gems via bundler
	local bundle_args="--deployment --without development"
	einfo "Running bundle install ${bundle_args} ..."
	${RUBY} /usr/bin/bundle install ${bundle_args} || die "bundler failed"

	# clean gems cache
	rm -Rf vendor/bundle/ruby/*/cache

	# insinto is slow, make hardlinks instead
	dodir ${DEST_DIR}
	cp -Rl . ${D}/${DEST_DIR} || die "failed to copy files"

	fperms +x ${DEST_DIR}/bin/{mailcatcher,catchmail}

	exeinto /usr/bin
	doexe ${T}/{mailcatcher,catchmail}

	newinitd ${FILESDIR}/${PN}.init ${PN}
	newconfd ${FILESDIR}/${PN}.conf ${PN}
}
