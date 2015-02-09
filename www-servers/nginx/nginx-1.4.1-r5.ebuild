# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

# Maintainer notes:
# - http_rewrite-independent pcre-support makes sense for matching locations without an actual rewrite
# - any http-module activates the main http-functionality and overrides USE=-http
# - keep the following requirements in mind before adding external modules:
#   * alive upstream
#   * sane packaging
#   * builds cleanly
#   * does not need a patch for nginx core
# - TODO: test the google-perftools module (included in vanilla tarball)

# prevent perl-module from adding automagic perl DEPENDs
GENTOO_DEPEND_ON_PERL="no"

# ruby config for passenger module
USE_RUBY="ree18 ruby19"
RUBY_OPTIONAL="yes"

# syslog
SYSLOG_MODULE_PV="0.25"
SYSLOG_MODULE_NGINX_PV="1.3.14"
SYSLOG_MODULE_P="ngx_syslog-${SYSLOG_MODULE_PV}"
SYSLOG_MODULE_URI="https://github.com/yaoweibin/nginx_syslog_patch/archive/v${SYSLOG_MODULE_PV}.tar.gz"
SYSLOG_MODULE_WD="${WORKDIR}/nginx_syslog_patch-${SYSLOG_MODULE_PV}"

# devel_kit (https://github.com/simpl/ngx_devel_kit, BSD license)
DEVEL_KIT_MODULE_PV="0.2.18"
DEVEL_KIT_MODULE_P="ngx_devel_kit-${DEVEL_KIT_MODULE_PV}-r1"
DEVEL_KIT_MODULE_URI="https://github.com/simpl/ngx_devel_kit/archive/v${DEVEL_KIT_MODULE_PV}.tar.gz"
DEVEL_KIT_MODULE_WD="${WORKDIR}/ngx_devel_kit-${DEVEL_KIT_MODULE_PV}"

# http_uploadprogress (https://github.com/masterzen/nginx-upload-progress-module, BSD-2 license)
HTTP_UPLOAD_PROGRESS_MODULE_PV="0.9.0"
HTTP_UPLOAD_PROGRESS_MODULE_P="ngx_http_upload_progress-${HTTP_UPLOAD_PROGRESS_MODULE_PV}-r1"
HTTP_UPLOAD_PROGRESS_MODULE_URI="https://github.com/masterzen/nginx-upload-progress-module/archive/v${HTTP_UPLOAD_PROGRESS_MODULE_PV}.tar.gz"
HTTP_UPLOAD_PROGRESS_MODULE_WD="${WORKDIR}/nginx-upload-progress-module-${HTTP_UPLOAD_PROGRESS_MODULE_PV}"

# http_headers_more (http://github.com/agentzh/headers-more-nginx-module, BSD license)
HTTP_HEADERS_MORE_MODULE_PV="0.20"
HTTP_HEADERS_MORE_MODULE_P="ngx_http_headers_more-${HTTP_HEADERS_MORE_MODULE_PV}-r1"
HTTP_HEADERS_MORE_MODULE_URI="https://github.com/agentzh/headers-more-nginx-module/archive/v${HTTP_HEADERS_MORE_MODULE_PV}.tar.gz"
HTTP_HEADERS_MORE_MODULE_WD="${WORKDIR}/headers-more-nginx-module-${HTTP_HEADERS_MORE_MODULE_PV}"

# http_push (http://pushmodule.slact.net/, MIT license)
HTTP_PUSH_MODULE_PV="0.692"
HTTP_PUSH_MODULE_P="ngx_http_push-${HTTP_PUSH_MODULE_PV}"
HTTP_PUSH_MODULE_URI="http://pushmodule.slact.net/downloads/nginx_http_push_module-${HTTP_PUSH_MODULE_PV}.tar.gz"
HTTP_PUSH_MODULE_WD="${WORKDIR}/nginx_http_push_module-${HTTP_PUSH_MODULE_PV}"

# http_cache_purge (http://labs.frickle.com/nginx_ngx_cache_purge/, BSD-2 license)
HTTP_CACHE_PURGE_MODULE_PV="2.1"
HTTP_CACHE_PURGE_MODULE_P="ngx_http_cache_purge-${HTTP_CACHE_PURGE_MODULE_PV}"
HTTP_CACHE_PURGE_MODULE_URI="http://labs.frickle.com/files/ngx_cache_purge-${HTTP_CACHE_PURGE_MODULE_PV}.tar.gz"
HTTP_CACHE_PURGE_MODULE_WD="${WORKDIR}/ngx_cache_purge-${HTTP_CACHE_PURGE_MODULE_PV}"

# http_slowfs_cache (http://labs.frickle.com/nginx_ngx_slowfs_cache/, BSD-2 license)
HTTP_SLOWFS_CACHE_MODULE_PV="1.10"
HTTP_SLOWFS_CACHE_MODULE_P="ngx_http_slowfs_cache-${HTTP_SLOWFS_CACHE_MODULE_PV}"
HTTP_SLOWFS_CACHE_MODULE_URI="http://labs.frickle.com/files/ngx_slowfs_cache-${HTTP_SLOWFS_CACHE_MODULE_PV}.tar.gz"
HTTP_SLOWFS_CACHE_MODULE_WD="${WORKDIR}/ngx_slowfs_cache-${HTTP_SLOWFS_CACHE_MODULE_PV}"

# http_fancyindex (http://wiki.nginx.org/NgxFancyIndex, BSD license)
HTTP_FANCYINDEX_MODULE_PV="0.3.1.1"
HTTP_FANCYINDEX_MODULE_P="ngx_http_fancyindex-${HTTP_FANCYINDEX_MODULE_PV}"
HTTP_FANCYINDEX_MODULE_URI="http://gitorious.org/ngx-fancyindex/ngx-fancyindex/archive-tarball/2034d0ad"
HTTP_FANCYINDEX_MODULE_WD="${WORKDIR}/ngx-fancyindex-ngx-fancyindex"

# http_lua (https://github.com/chaoslawful/lua-nginx-module, BSD license)
HTTP_LUA_MODULE_PV="0.8.1"
HTTP_LUA_MODULE_P="ngx_http_lua-${HTTP_LUA_MODULE_PV}"
HTTP_LUA_MODULE_URI="https://github.com/chaoslawful/lua-nginx-module/archive/v${HTTP_LUA_MODULE_PV}.tar.gz"
HTTP_LUA_MODULE_WD="${WORKDIR}/lua-nginx-module-${HTTP_LUA_MODULE_PV}"

# http_auth_pam (http://web.iti.upv.es/~sto/nginx/, unknown license)
HTTP_AUTH_PAM_MODULE_PV="1.2"
HTTP_AUTH_PAM_MODULE_P="ngx_http_auth_pam-${HTTP_AUTH_PAM_MODULE_PV}"
HTTP_AUTH_PAM_MODULE_URI="http://web.iti.upv.es/~sto/nginx/ngx_http_auth_pam_module-${HTTP_AUTH_PAM_MODULE_PV}.tar.gz"
HTTP_AUTH_PAM_MODULE_WD="${WORKDIR}/ngx_http_auth_pam_module-${HTTP_AUTH_PAM_MODULE_PV}"

# http_upstream_check (https://github.com/yaoweibin/nginx_upstream_check_module, BSD license)
HTTP_UPSTREAM_CHECK_MODULE_PV="99f39394f387211641a1668d61faf2d5186ea1f5"
HTTP_UPSTREAM_CHECK_MODULE_P="ngx_http_upstream_check-${HTTP_UPSTREAM_CHECK_MODULE_PV}"
HTTP_UPSTREAM_CHECK_MODULE_URI="https://github.com/yaoweibin/nginx_upstream_check_module/archive/${HTTP_UPSTREAM_CHECK_MODULE_PV}.tar.gz"
HTTP_UPSTREAM_CHECK_MODULE_WD="${WORKDIR}/nginx_upstream_check_module-${HTTP_UPSTREAM_CHECK_MODULE_PV}"

# http_metrics (https://github.com/madvertise/ngx_metrics, BSD license)
HTTP_METRICS_MODULE_PV="0.1.1"
HTTP_METRICS_MODULE_P="ngx_metrics-${HTTP_METRICS_MODULE_PV}"
HTTP_METRICS_MODULE_URI="https://github.com/madvertise/ngx_metrics/archive/v${HTTP_METRICS_MODULE_PV}.tar.gz"
HTTP_METRICS_MODULE_WD="${WORKDIR}/ngx_metrics-${HTTP_METRICS_MODULE_PV}"

# naxsi-core (https://code.google.com/p/naxsi/, GPLv2+)
HTTP_NAXSI_MODULE_PV="0.50"
HTTP_NAXSI_MODULE_P="ngx_http_naxsi-${HTTP_NAXSI_MODULE_PV}"
HTTP_NAXSI_MODULE_URI="https://naxsi.googlecode.com/files/naxsi-core-${HTTP_NAXSI_MODULE_PV}.tgz"
HTTP_NAXSI_MODULE_WD="${WORKDIR}/naxsi-core-${HTTP_NAXSI_MODULE_PV}/naxsi_src"

# HTTP Passenger module
HTTP_PASSENGER_MODULE_PV="3.0.19"
HTTP_PASSENGER_MODULE_P="passenger-${HTTP_PASSENGER_MODULE_PV}"
HTTP_PASSENGER_MODULE_URI="mirror://rubyforge/passenger/${HTTP_PASSENGER_MODULE_P}.tar.gz"
HTTP_PASSENGER_MODULE_WD="${WORKDIR}/passenger-${HTTP_PASSENGER_MODULE_PV}"

# http_sticky (http://code.google.com/p/nginx-sticky-module/, as-is)
HTTP_STICKY_MODULE_PV="1.1"
HTTP_STICKY_MODULE_P="nginx-sticky-module-${HTTP_STICKY_MODULE_PV}"
HTTP_STICKY_MODULE_URI="http://nginx-sticky-module.googlecode.com/files/${HTTP_STICKY_MODULE_P}.tar.gz"
HTTP_STICKY_MODULE_WD="${WORKDIR}/${HTTP_STICKY_MODULE_P}"

# ngx_echo (https://github.com/agentzh/echo-nginx-module, BSD)
HTTP_ECHO_MODULE_PV="0.45"
HTTP_ECHO_MODULE_P="echo-nginx-module-${HTTP_ECHO_MODULE_PV}"
HTTP_ECHO_MODULE_URI="https://github.com/agentzh/echo-nginx-module/archive/v${HTTP_ECHO_MODULE_PV}.tar.gz"
HTTP_ECHO_MODULE_WD="${WORKDIR}/${HTTP_ECHO_MODULE_P}"


inherit eutils ssl-cert toolchain-funcs perl-module ruby-ng flag-o-matic user versionator

DESCRIPTION="Robust, small and high performance http and reverse proxy server"
HOMEPAGE="http://nginx.org"
SRC_URI="http://nginx.org/download/${P}.tar.gz
	syslog? ( ${SYSLOG_MODULE_URI} -> ${SYSLOG_MODULE_P}.tar.gz )
	${DEVEL_KIT_MODULE_URI} -> ${DEVEL_KIT_MODULE_P}.tar.gz
	nginx_modules_http_upload_progress? ( ${HTTP_UPLOAD_PROGRESS_MODULE_URI} -> ${HTTP_UPLOAD_PROGRESS_MODULE_P}.tar.gz )
	nginx_modules_http_headers_more? ( ${HTTP_HEADERS_MORE_MODULE_URI} -> ${HTTP_HEADERS_MORE_MODULE_P}.tar.gz )
	nginx_modules_http_push? ( ${HTTP_PUSH_MODULE_URI} -> ${HTTP_PUSH_MODULE_P}.tar.gz )
	nginx_modules_http_cache_purge? ( ${HTTP_CACHE_PURGE_MODULE_URI} -> ${HTTP_CACHE_PURGE_MODULE_P}.tar.gz )
	nginx_modules_http_slowfs_cache? ( ${HTTP_SLOWFS_CACHE_MODULE_URI} -> ${HTTP_SLOWFS_CACHE_MODULE_P}.tar.gz )
	nginx_modules_http_fancyindex? ( ${HTTP_FANCYINDEX_MODULE_URI} -> ${HTTP_FANCYINDEX_MODULE_P}.tar.gz )
	nginx_modules_http_lua? ( ${HTTP_LUA_MODULE_URI} -> ${HTTP_LUA_MODULE_P}.tar.gz )
	nginx_modules_http_auth_pam? ( ${HTTP_AUTH_PAM_MODULE_URI} -> ${HTTP_AUTH_PAM_MODULE_P}.tar.gz )
	nginx_modules_http_upstream_check? ( ${HTTP_UPSTREAM_CHECK_MODULE_URI} -> ${HTTP_UPSTREAM_CHECK_MODULE_P}.tar.gz )
	nginx_modules_http_metrics? ( ${HTTP_METRICS_MODULE_URI} -> ${HTTP_METRICS_MODULE_P}.tar.gz )
	nginx_modules_http_naxsi? ( ${HTTP_NAXSI_MODULE_URI} -> ${HTTP_NAXSI_MODULE_P}.tar.gz )
	nginx_modules_http_passenger? ( ${HTTP_PASSENGER_MODULE_URI} -> ${HTTP_PASSENGER_MODULE_P}.tar.gz )
	nginx_modules_http_sticky? ( ${HTTP_STICKY_MODULE_URI} -> ${HTTP_STICKY_MODULE_P}.tar.gz )
	nginx_modules_http_echo? ( ${HTTP_ECHO_MODULE_URI} -> ${HTTP_ECHO_MODULE_P}.tar.gz )"

LICENSE="BSD-2 BSD SSLeay MIT GPL-2 GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"

NGINX_MODULES_STD="access auth_basic autoindex browser charset empty_gif fastcgi
geo gzip limit_req limit_conn map memcached proxy referer rewrite scgi ssi
split_clients upstream_ip_hash userid uwsgi"
NGINX_MODULES_OPT="addition dav degradation flv geoip gunzip gzip_static image_filter
mp4 perl random_index realip secure_link spdy stub_status sub xslt"
NGINX_MODULES_MAIL="imap pop3 smtp"
NGINX_MODULES_3RD="
	http_upload_progress
	http_headers_more
	http_push
	http_cache_purge
	http_slowfs_cache
	http_fancyindex
	http_lua
	http_auth_pam
	http_upstream_check
	http_metrics
	http_naxsi
	http_passenger
	http_sticky
	http_echo"

IUSE="aio debug +http +http-cache ipv6 libatomic +pcre pcre-jit selinux ssl
syslog userland_GNU vim-syntax"

RUBY_S="${P}"
# return S to default after ruby-ng has modified it
S="${WORKDIR}/${RUBY_S}"


for mod in $NGINX_MODULES_STD; do
	IUSE="${IUSE} +nginx_modules_http_${mod}"
done

for mod in $NGINX_MODULES_OPT; do
	IUSE="${IUSE} nginx_modules_http_${mod}"
done

for mod in $NGINX_MODULES_MAIL; do
	IUSE="${IUSE} nginx_modules_mail_${mod}"
done

for mod in $NGINX_MODULES_3RD; do
	IUSE="${IUSE} nginx_modules_${mod}"
done

ruby_add_bdepend "nginx_modules_http_passenger? (
	dev-ruby/rake )"

ruby_add_rdepend "nginx_modules_http_passenger? (
	>=dev-ruby/daemon_controller-1.0.0
	>=dev-ruby/rack-1.0.0 )"

CDEPEND="
	pcre? ( >=dev-libs/libpcre-4.2 )
	pcre-jit? ( >=dev-libs/libpcre-8.20[jit] )
	selinux? ( sec-policy/selinux-nginx )
	ssl? ( dev-libs/openssl )
	http-cache? ( userland_GNU? ( dev-libs/openssl ) )
	nginx_modules_http_geo? ( dev-libs/geoip )
	nginx_modules_http_gunzip? ( sys-libs/zlib )
	nginx_modules_http_gzip? ( sys-libs/zlib )
	nginx_modules_http_gzip_static? ( sys-libs/zlib )
	nginx_modules_http_image_filter? ( media-libs/gd[jpeg,png] )
	nginx_modules_http_perl? ( >=dev-lang/perl-5.8 )
	nginx_modules_http_rewrite? ( >=dev-libs/libpcre-4.2 )
	nginx_modules_http_secure_link? ( userland_GNU? ( dev-libs/openssl ) )
	nginx_modules_http_spdy? ( >=dev-libs/openssl-1.0.1c )
	nginx_modules_http_xslt? ( dev-libs/libxml2 dev-libs/libxslt )
	nginx_modules_http_lua? ( || ( dev-lang/lua dev-lang/luajit ) )
	nginx_modules_http_auth_pam? ( virtual/pam )
	nginx_modules_http_metrics? ( dev-libs/yajl )
	nginx_modules_http_passenger? ( 
		>=dev-libs/libev-3.90 
		ruby_targets_ree18? ( $(ruby_implementation_depend ree18)[ssl] )
		ruby_targets_ruby19? ( $(ruby_implementation_depend ruby19)[ssl] ) )"

RDEPEND="${RDEPEND} ${CDEPEND}"
DEPEND="${DEPEND} ${CDEPEND}
	arm? ( dev-libs/libatomic_ops )
	libatomic? ( dev-libs/libatomic_ops )"
PDEPEND="vim-syntax? ( app-vim/nginx-syntax )"

REQUIRED_USE="pcre-jit? ( pcre )
	nginx_modules_http_lua? ( nginx_modules_http_rewrite )
	nginx_modules_http_naxsi? ( pcre )
	nginx_modules_http_passenger? ( 
		|| ( ruby_targets_ree18 ruby_targets_ruby19 )
		ssl
	)"

pkg_setup() {
	NGINX_HOME="/var/lib/nginx"
	NGINX_HOME_TMP="${NGINX_HOME}/tmp"

	ebegin "Creating nginx user and group"
	enewgroup ${PN}
	enewuser ${PN} -1 -1 "${NGINX_HOME}" ${PN}
	eend $?

	if use libatomic; then
		ewarn "GCC 4.1+ features built-in atomic operations."
		ewarn "Using libatomic_ops is only needed if using"
		ewarn "a different compiler or a GCC prior to 4.1"
	fi

	if [[ -n $NGINX_ADD_MODULES ]]; then
		ewarn "You are building custom modules via \$NGINX_ADD_MODULES!"
		ewarn "This nginx installation is not supported!"
		ewarn "Make sure you can reproduce the bug without those modules"
		ewarn "_before_ reporting bugs."
	fi

	if use !http; then
		ewarn "To actually disable all http-functionality you also have to disable"
		ewarn "all nginx http modules."
	fi

	if use nginx_modules_http_passenger; then
		ruby-ng_pkg_setup
		use debug && append-flags -DPASSENGER_DEBUG
	fi
}

src_unpack() {
	# prevent ruby-ng.eclass from messing with src_unpack
	default
}

src_prepare() {
	epatch "${FILESDIR}/${P}-fix-perl-install-path.patch"

	if use syslog; then
		epatch "${SYSLOG_MODULE_WD}"/syslog_${SYSLOG_MODULE_NGINX_PV}.patch
	fi

	if use nginx_modules_http_upstream_check; then
		epatch "${HTTP_UPSTREAM_CHECK_MODULE_WD}"/check_1.2.6+.patch
	fi

	find auto/ -type f -print0 | xargs -0 sed -i 's:\&\& make:\&\& \\$(MAKE):' || die
	# We have config protection, don't rename etc files
	sed -i 's:.default::' auto/install || die
	# remove useless files
	sed -i -e '/koi-/d' -e '/win-/d' auto/install || die

	epatch_user

	if use nginx_modules_http_passenger; then
		cd "${HTTP_PASSENGER_MODULE_WD}"
		epatch \
			"${FILESDIR}/passenger-3.0.14-ldflags.patch" \
			"${FILESDIR}/passenger-3.0.11-cflags.patch"

		sed -i \
			-e 's|/usr/lib/phusion-passenger/agents|/usr/libexec/passenger/agents|' \
			-e 's|/usr/share/phusion-passenger/helper-scripts|/usr/libexec/passenger/bin|' \
			-e "s|/usr/share/doc/phusion-passenger|/usr/share/doc/${PF}|" \
			lib/phusion_passenger.rb ext/common/ResourceLocator.h || die "sed failed"

		sed -i \
			-e "s/gcc/$(tc-getCC)/" \
			-e "s/g++/$(tc-getCXX)/" \
			build/config.rb || die "failed to filter config.rb"

		# Don't install a tool that won't work in our setup.
		sed -i -e '/passenger-install-apache2-module/d' \
			lib/phusion_passenger/packaging.rb \
			|| die "failed to filter packaging.rb"

		rm -f bin/passenger-install-apache2-module \
			|| die "Unable to remove unneeded install script."

		# Make sure we use the system-provided version.
		rm -rf ext/libev || die "Unable to remove vendored libev."

		# fix automagic use of asciidoc, bug 413469
		sed -i -e '/fakeroot/ s/+ Packaging::ASCII_DOCS//' \
			build/packaging.rb || die "failed to filter packaging.rb"
	fi
}

src_configure() {
	local myconf= http_enabled= mail_enabled=

	use aio       && myconf+=" --with-file-aio --with-aio_module"
	use debug     && myconf+=" --with-debug"
	use ipv6      && myconf+=" --with-ipv6"
	use libatomic && myconf+=" --with-libatomic"
	use pcre      && myconf+=" --with-pcre"
	use pcre-jit  && myconf+=" --with-pcre-jit"

	# syslog support
	if use syslog; then
		myconf+=" --add-module=${SYSLOG_MODULE_WD}"
	fi

	# HTTP modules
	for mod in $NGINX_MODULES_STD; do
		if use nginx_modules_http_${mod}; then
			http_enabled=1
		else
			myconf+=" --without-http_${mod}_module"
		fi
	done

	for mod in $NGINX_MODULES_OPT; do
		if use nginx_modules_http_${mod}; then
			http_enabled=1
			myconf+=" --with-http_${mod}_module"
		fi
	done

	if use nginx_modules_http_fastcgi; then
		myconf+=" --with-http_realip_module"
	fi

	# third-party modules
	if use nginx_modules_http_upload_progress; then
		http_enabled=1
		myconf+=" --add-module=${HTTP_UPLOAD_PROGRESS_MODULE_WD}"
	fi

	if use nginx_modules_http_headers_more; then
		http_enabled=1
		myconf+=" --add-module=${HTTP_HEADERS_MORE_MODULE_WD}"
	fi

	if use nginx_modules_http_push; then
		http_enabled=1
		myconf+=" --add-module=${HTTP_PUSH_MODULE_WD}"
	fi

	if use nginx_modules_http_cache_purge; then
		http_enabled=1
		myconf+=" --add-module=${HTTP_CACHE_PURGE_MODULE_WD}"
	fi

	if use nginx_modules_http_slowfs_cache; then
		http_enabled=1
		myconf+=" --add-module=${HTTP_SLOWFS_CACHE_MODULE_WD}"
	fi

	if use nginx_modules_http_fancyindex; then
		http_enabled=1
		myconf+=" --add-module=${HTTP_FANCYINDEX_MODULE_WD}"
	fi

	if use nginx_modules_http_lua; then
		http_enabled=1
		myconf+=" --add-module=${DEVEL_KIT_MODULE_WD}"
		myconf+=" --add-module=${HTTP_LUA_MODULE_WD}"
	fi

	if use nginx_modules_http_auth_pam; then
		http_enabled=1
		myconf+=" --add-module=${HTTP_AUTH_PAM_MODULE_WD}"
	fi

	if use nginx_modules_http_upstream_check; then
		http_enabled=1
		myconf+=" --add-module=${HTTP_UPSTREAM_CHECK_MODULE_WD}"
	fi

	if use nginx_modules_http_metrics; then
		http_enabled=1
		myconf+=" --add-module=${HTTP_METRICS_MODULE_WD}"
	fi

	if use nginx_modules_http_naxsi ; then
		http_enabled=1
		myconf+=" --add-module=${HTTP_NAXSI_MODULE_WD}"
	fi

	if use nginx_modules_http_passenger; then
		http_enabled=1
		myconf+=" --add-module=${HTTP_PASSENGER_MODULE_WD}/ext/nginx"
	fi

	if use nginx_modules_http_sticky; then
		http_enabled=1
		myconf+=" --add-module=${HTTP_STICKY_MODULE_WD}"
	fi

	if use nginx_modules_http_echo; then
		http_enabled=1
		myconf+=" --add-module=${HTTP_ECHO_MODULE_WD}"
	fi

	if use http || use http-cache; then
		http_enabled=1
	fi

	if [ $http_enabled ]; then
		use http-cache || myconf+=" --without-http-cache"
		use ssl && myconf+=" --with-http_ssl_module"
	else
		myconf+=" --without-http --without-http-cache"
	fi

	# MAIL modules
	for mod in $NGINX_MODULES_MAIL; do
		if use nginx_modules_mail_${mod}; then
			mail_enabled=1
		else
			myconf+=" --without-mail_${mod}_module"
		fi
	done

	if [ $mail_enabled ]; then
		myconf+=" --with-mail"
		use ssl && myconf+=" --with-mail_ssl_module"
	fi

	# custom modules
	for mod in $NGINX_ADD_MODULES; do
		myconf+=" --add-module=${mod}"
	done

	# https://bugs.gentoo.org/286772
	export LANG=C LC_ALL=C
	tc-export CC

	if ! use prefix; then
		myconf+=" --user=${PN} --group=${PN}"
	fi

	./configure \
		--prefix="${EPREFIX}"/usr \
		--conf-path="${EPREFIX}"/etc/${PN}/${PN}.conf \
		--error-log-path="${EPREFIX}"/var/log/${PN}/error.log \
		--pid-path="${EPREFIX}"/run/${PN}.pid \
		--lock-path="${EPREFIX}"/run/lock/${PN}.lock \
		--with-cc-opt="-I${EROOT}usr/include" \
		--with-ld-opt="-L${EROOT}usr/lib" \
		--http-log-path="${EPREFIX}"/var/log/${PN}/access.log \
		--http-client-body-temp-path="${EPREFIX}/${NGINX_HOME_TMP}"/client \
		--http-proxy-temp-path="${EPREFIX}/${NGINX_HOME_TMP}"/proxy \
		--http-fastcgi-temp-path="${EPREFIX}/${NGINX_HOME_TMP}"/fastcgi \
		--http-scgi-temp-path="${EPREFIX}/${NGINX_HOME_TMP}"/scgi \
		--http-uwsgi-temp-path="${EPREFIX}/${NGINX_HOME_TMP}"/uwsgi \
		${myconf} || die "configure failed"
}

src_compile() {
	# https://bugs.gentoo.org/286772
	export LANG=C LC_ALL=C
	emake LINK="${CC} ${LDFLAGS}" OTHERLDFLAGS="${LDFLAGS}"
}

src_install() {
	emake DESTDIR="${D}" install

	cp "${FILESDIR}"/conf/nginx.conf "${ED}"/etc/nginx/nginx.conf || die

	newinitd "${FILESDIR}"/nginx.initd-r2 nginx

	doman man/nginx.8
	dodoc CHANGES* README

	insinto /etc/nginx/sites
	doins "${FILESDIR}"/conf/default.conf

	insinto /etc/nginx/incl
	doins "${FILESDIR}"/conf/{proxy_headers.conf,handle_favicon.conf}
	use nginx_modules_http_sub && doins "${FILESDIR}"/conf/analytics.conf

	# remove useless files
	local conf="${ED}"/etc/nginx
	! use nginx_modules_http_fastcgi && rm "${conf}"/fastcgi{.conf,_params}
	! use nginx_modules_http_scgi && rm "${conf}"/scgi_params
	! use nginx_modules_http_uwsgi && rm "${conf}"/uwsgi_params

	# just keepdir. do not copy the default htdocs files (bug #449136)
	keepdir /var/www/localhost
	rm -rf "${D}"/usr/html || die

	keepdir /var/log/nginx "${NGINX_HOME_TMP}"/{,client,proxy,fastcgi,scgi,uwsgi}
	fperms 0700 /var/log/nginx "${NGINX_HOME_TMP}"/{,client,proxy,fastcgi,scgi,uwsgi}
	fowners ${PN}:${PN} /var/log/nginx "${NGINX_HOME_TMP}"/{,client,proxy,fastcgi,scgi,uwsgi}

	# logrotate
	insinto /etc/logrotate.d
	newins "${FILESDIR}"/nginx.logrotate nginx

	if use nginx_modules_http_perl; then
		cd "${S}"/objs/src/http/modules/perl/
		einstall DESTDIR="${D}" INSTALLDIRS=vendor
		fixlocalpod
	fi

	if use syslog; then
		docinto ${SYSLOG_MODULE_P}
		dodoc "${SYSLOG_MODULE_WD}"/README
	fi

	if use nginx_modules_http_push; then
		docinto ${HTTP_PUSH_MODULE_P}
		dodoc "${HTTP_PUSH_MODULE_WD}"/{changelog.txt,protocol.txt,README}
	fi

	if use nginx_modules_http_cache_purge; then
		docinto ${HTTP_CACHE_PURGE_MODULE_P}
		dodoc "${HTTP_CACHE_PURGE_MODULE_WD}"/{CHANGES,README.md,TODO.md}
	fi

	if use nginx_modules_http_slowfs_cache; then
		docinto ${HTTP_SLOWFS_CACHE_MODULE_P}
		dodoc "${HTTP_SLOWFS_CACHE_MODULE_WD}"/{CHANGES,README.md}
	fi

	if use nginx_modules_http_fancyindex; then
		docinto ${HTTP_FANCYINDEX_MODULE_P}
		dodoc "${HTTP_FANCYINDEX_MODULE_WD}"/README.rst
	fi

	if use nginx_modules_http_lua; then
		docinto ${HTTP_LUA_MODULE_P}
		dodoc "${HTTP_LUA_MODULE_WD}"/{Changes,README.markdown}
	fi

	if use nginx_modules_http_auth_pam; then
		docinto ${HTTP_AUTH_PAM_MODULE_P}
		dodoc "${HTTP_AUTH_PAM_MODULE_WD}"/{README,ChangeLog}
	fi

	if use nginx_modules_http_upstream_check; then
		docinto ${HTTP_UPSTREAM_CHECK_MODULE_P}
		dodoc "${HTTP_UPSTREAM_CHECK_MODULE_WD}"/{README,CHANGES}
	fi

	if use nginx_modules_http_metrics; then
		docinto ${HTTP_METRICS_MODULE_P}
		dodoc "${HTTP_METRICS_MODULE_WD}"/README.md
	fi

	if use nginx_modules_http_naxsi; then
		insinto /etc/nginx
		doins "${HTTP_NAXSI_MODULE_WD}"/../naxsi_config/naxsi_core.rules

		docinto ${HTTP_NAXSI_MODULE_P}
		newdoc "${HTTP_NAXSI_MODULE_WD}"/../naxsi_config/default_location_config.example nbs.rules
	fi

	if use nginx_modules_http_sticky; then
		docinto ${HTTP_STICKY_MODULE_P}
		dodoc "${HTTP_STICKY_MODULE_WD}"/README
	fi

	if use nginx_modules_http_echo; then
		docinto ${HTTP_ECHO_MODULE_P}
		dodoc "${HTTP_ECHO_MODULE_WD}"/README
	fi

	if use nginx_modules_http_passenger; then
		# passengers Rakefile is so horribly broken that we have to do it
		# manually
		cd "${HTTP_PASSENGER_MODULE_WD}"

		for target in $(ruby_get_use_implementations); do
			einfo "Install ${HTTP_PASSENGER_MODULE_P} for target ${target}"
			export RUBY="${target}"

			insinto $(ruby_rbconfig_value 'archdir')
			insopts -m 0755
			doins ext/ruby/*/passenger_native_support.so
			doruby -r lib/phusion_passenger lib/phusion_passenger.rb

			exeinto /usr/bin
			doexe bin/passenger-memory-stats bin/passenger-status

			exeinto /usr/libexec/passenger/bin
			doexe helper-scripts/passenger-spawn-server

			exeinto /usr/libexec/passenger/agents
			doexe agents/Passenger{LoggingAgent,Watchdog}

			exeinto /usr/libexec/passenger/agents/nginx
			doexe agents/nginx/PassengerHelperAgent

			# set correct paths to nginx.conf
			# note: passenger doesn't support multiple targets at one so only
			# first one will be used
			local ruby_bin=$(ruby_implementation_command ${RUBY})
			local sitelibdir=$(ruby_rbconfig_value 'sitelibdir')
			sed -i \
				-e "s|@PASSENGER_ROOT@|${sitelibdir}/phusion_passenger|" \
				-e "s|@RUBY_BIN@|${ruby_bin}|" \
				"${ED}"/etc/nginx/nginx.conf || die "failed to filter nginx.conf"
		done
	else
		# remove configuration for passanger if not USEd
		sed -i \
			-e "/passenger_/d" "${ED}"/etc/nginx/nginx.conf \
			|| die "failed to filter nginx.conf"
	fi

}

pkg_postinst() {
	if use ssl; then
		if [ ! -f "${EROOT}"/etc/ssl/${PN}/${PN}.key ]; then
			install_cert /etc/ssl/${PN}/${PN}
			use prefix || chown ${PN}:${PN} "${EROOT}"/etc/ssl/${PN}/${PN}.{crt,csr,key,pem}
		fi
	fi

	if use nginx_modules_http_lua && use nginx_modules_http_spdy; then
		ewarn "Lua 3rd party module author warns against using ${P} with"
		ewarn "NGINX_MODULES_HTTP=\"lua spdy\". For more info, see http://git.io/OldLsg"
	fi

	# This is the proper fix for bug #458726/#469094, resp. CVE-2013-0337 for
	# existing installations
	local fix_perms=0

	for rv in ${REPLACING_VERSIONS} ; do
		version_compare ${rv} 1.4.1-r2
		[[ $? -eq 1 ]] && fix_perms=1
	done

	if [[ $fix_perms -eq 1 ]] ; then
		ewarn "To fix a security bug (CVE-2013-0337, bug #458726) had the following"
		ewarn "directories the world-readable bit removed (if set):"
		ewarn "  ${EPREFIX}/var/log/nginx"
		ewarn "  ${EPREFIX}${NGINX_HOME_TMP}/{,client,proxy,fastcgi,scgi,uwsgi}"
		ewarn "Check if this is correct for your setup before restarting nginx!"
		ewarn "This is a one-time change and will not happen on subsequent updates."
		ewarn "Furthermore nginx' temp directories got moved to ${NGINX_HOME_TMP}"
		chmod o-rwx "${EPREFIX}"/var/log/nginx "${EPREFIX}/${NGINX_HOME_TMP}"/{,client,proxy,fastcgi,scgi,uwsgi}
	fi

	if use ipv6; then
		ewarn
		ewarn "The 'ipv6only' parameter is now turned *on* by default for listening IPv6"
		ewarn "sockets! You should either list both IPv6 and IPv4 listen sockets, or"
		ewarn "explicitly switch off ipv6only for IPv6 sockets."
	fi
}
