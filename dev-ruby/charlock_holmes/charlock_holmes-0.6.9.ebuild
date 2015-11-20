# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

USE_RUBY="ruby18 ruby19"

RUBY_FAKEGEM_RECIPE_TEST="rspec"
RUBY_FAKEGEM_EXTRADOC="README.md"
RUBY_FAKEGEM_GEMSPEC="${PN}.gemspec"

inherit ruby-fakegem

DESCRIPTION="Character encoding detection, brought to you by ICU"
HOMEPAGE="http://github.com/brianmario/charlock_holmes"
SRC_URI="https://github.com/brianmario/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# test needs gem chardet which is not in Portage yet
RESTRICT="test"

DEPEND="${DEPEND}
	dev-libs/icu"

ruby_add_rdepend "
	virtual/rubygems"

# don't bundle file/libmagic
# avoid underlinking by linking against libz, libicuuc and libicudata
RUBY_PATCHES="charlock_holmes-0.6.9-extconf.patch"

MY_EXT_DIR="ext/charlock_holmes"

each_ruby_configure() {
	${RUBY} -C${MY_EXT_DIR} extconf.rb || die "extconf.rb failed"
}

each_ruby_compile() {
	emake -C${MY_EXT_DIR} || die "emake failed"
	cp -l ${MY_EXT_DIR}/charlock_holmes$(get_modname) lib/charlock_holmes \
		|| die "failed to copy ext"
}
