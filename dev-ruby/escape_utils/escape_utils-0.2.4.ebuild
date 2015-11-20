# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

USE_RUBY="ruby18 ruby19"

RUBY_FAKEGEM_RECIPE_TEST="rspec"
RUBY_FAKEGEM_EXTRADOC="README.md"
RUBY_FAKEGEM_GEMSPEC="${PN}.gemspec"

inherit ruby-fakegem

DESCRIPTION="Faster string escaping routines for ruby apps"
HOMEPAGE="https://github.com/brianmario/escape_utils"
SRC_URI="https://github.com/brianmario/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

ruby_add_rdepend "
	virtual/rubygems"

ruby_add_bdepend "
	test? ( >=dev-ruby/rake-compiler-0.7.5 )"

MY_EXT_DIR="ext/escape_utils"


each_ruby_configure() {
	${RUBY} -C${MY_EXT_DIR} extconf.rb || die "extconf.rb failed"
}

each_ruby_compile() {
	emake -C${MY_EXT_DIR} || die "emake failed"

	mkdir lib/${PN}/ext || die
	cp -l ${MY_EXT_DIR}/${PN}$(get_modname) lib/${PN}/ext \
		|| die "failed to copy ext"
}
