# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

# Maintainer notes:
# - This ebuild is not fully tested, some modules may not work!
# - Replace filter-python, table-python... with just python?

PYTHON_COMPAT=( python2_7 )

inherit multilib flag-o-matic eutils toolchain-funcs autotools python-single-r1 git-r3 versionator

DESCRIPTION="Official addons for OpenSMTPD"
HOMEPAGE="http://www.opensmtpd.org/"
SRC_URI=""

EGIT_REPO_URI="https://github.com/OpenSMTPD/OpenSMTPD-extras.git git://github.com/OpenSMTPD/OpenSMTPD-extras.git"
EGIT_BRANCH="portable"

LICENSE="ISC BSD BSD-1 BSD-2 BSD-4"
SLOT="0"
KEYWORDS="~amd64 ~x86"

OPENSMTPD_FILTERS="dkim-signer dnsbl monkey perl python stub trace void"
OPENSMTPD_QUEUES="null python ram stub"
OPENSMTPD_SCHEDULERS="python ram stub"
OPENSMTPD_TABLES="ldap mysql passwd postgres python redis socketmap sqlite stub"

OPENSMTPD_MODULES_USE=()

for mod in $OPENSMTPD_FILTERS; do
	OPENSMTPD_MODULES_USE+=( "filter-$mod" )
done

for mod in $OPENSMTPD_QUEUES; do
	OPENSMTPD_MODULES_USE+=( "queue-$mod" )
done

for mod in $OPENSMTPD_SCHEDULERS; do
	OPENSMTPD_MODULES_USE+=( "scheduler-$mod" )
done

for mod in $OPENSMTPD_TABLES; do
	OPENSMTPD_MODULES_USE+=( "table-$mod" )
done

IUSE="pam ${OPENSMTPD_MODULES_USE[@]}"

DEPEND=">=mail-mta/opensmtpd-5.5
		filter-python? ( $PYTHON_DEPS )
		filter-perl? ( dev-lang/perl )
		queue-python? ( $PYTHON_DEPS )
		scheduler-python? ( $PYTHON_DEPS )
		table-mysql? ( virtual/mysql )
		table-postgres? ( virtual/postgresql )
		table-python? ( $PYTHON_DEPS )
		table-redis? ( dev-db/redis )
		table-sqlite? ( dev-db/sqlite:3 )"
RDEPEND="${DEPEND}"


src_prepare() {
	local mkfile name dir

	for mkfile in mk/*/Makefile.am; do
		echo 'SUBDIRS =' > $mkfile || die "failed to truncate $mkfile"
	done

	# If module is USEd, add it back to its parent makefile, otherwise remove
	# it from configure.ac to not be compiled.
	for name in ${OPENSMTPD_MODULES_USE[@]}; do
		dir=${name%%-*}s
		if use $name; then
			sed -i -e "/SUBDIRS =/ s/$/ $name/" mk/$dir/Makefile.am || die
		else
			sed -i -e "/mk\/$dir\/$name\/Makefile/d" configure.ac || die
		fi
	done

	epatch_user
	eautoreconf
}

src_configure() {
	tc-export AR
	AR="$(which "$AR")" econf \
		--with-privsep-user=smtpd \
		--with-queue-user=smtpq \
		--with-privsep-path=/var/empty \
		--with-sock-dir=/run \
		--sysconfdir=/etc/opensmtpd \
		--with-ca-file=/etc/ssl/certs/ca-certificates.crt \
		$(use_with pam)
}
