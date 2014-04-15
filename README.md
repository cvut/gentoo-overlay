CVUT Gentoo overlay
===================

Gentoo overlay with some ebuilds created or modified on [CTU](http://www.cvut.cz/) and are not yet in the official repository.


List of ebuilds
---------------

* **app-crypt/easy-rsa** (2.2.0)
   * with patch for [subjectAltName](http://www.msquared.id.au/articles/easy-rsa-subjectaltname/)
* **app-misc/alfresco-bin** (4.2.b, 4.2d)
   * with Share, GoogleDocs integration, SOLR server
* **app-misc/alfresco-solr-bin** (4.2.b)
* **app-misc/apache-servicemix-bin** (4.5.1)
* **app-misc/openidm** (2.1.0)
* **dev-db/mongodb (2.4.6)**
   * with patch for [SERVER-9248](https://jira.mongodb.org/browse/SERVER-9248)
* **dev-java/artifactory-bin** (2.6.6)
* **dev-java/jboss-as-bin** (7.1)
   * binary package, standalone mode only, proper init script included!
* **dev-java/jdbc-mysql-bin** (5.1.18)
   * jdbc-mysql can’t be built on JDK 7, so there’s a binary package…
* **dev-java/jdbc-oracle-bin** (12.1)
* **dev-java/rhino** (1.7R4)
* **dev-lang/ruby** (1.9.3\_p194, 1.9.3\_p286)
   * with [“Falcon”](https://gist.github.com/4136519) performance patches and backported COW-friendly GC
* **dev-libs/opensaml** (2.4.3)
   * dependency for shibboleth-sp
* **dev-libs/xmltooling-c** (1.4.2)
   * dependency for shibboleth-sp
* **dev-lua/luaexpat** (1.3.0)
* **dev-lua/lualdap** (git)
* **dev-python/docopt** (0.6.1)
* **dev-ruby/bundler** (1.3.5)
   * with `ruby_targets_ruby20` flag
* **dev-util/activiti-bin** (5.14)
* **dev-util/sonar-bin** (3.2, 3.5, 3.7)
   * proper ebuild, much better than godin’s :)
* **dev-vcs/gitlab-shell** (1.7.1, 1.8.0)
* **dev-vcs/gitolite** (3.2)
   * [Gitolite](https://github.com/sitaramc/gitolite) ebuild with added optional patch for GitLab (see [commits](https://github.com/gitlabhq/gitolite/commits/))
* **mail-mta/mailcatcher** (0.5.12)
   * [mailcatcher](https://github.com/sj26/mailcatcher) with [persist patch](https://github.com/sj26/mailcatcher/pull/109) and removed exit button, intended for a standalone usage, init script included
* **media-gfx/swftools** (0.9.2)
   * with enabled pdf2swf without poppler (see [#412423](https://bugs.gentoo.org/show_bug.cgi?id=412423))
* **net-im/openfire** (3.8.1)
* **net-misc/minidlna** (1.0.24)
   * with improved ebuild and init script
* **www-apps/gitlabhq** (4.0.0, 6.0.2, 6.5.1)
   * with some fixes and enhacements
* **www-apps/haste-client** (1.0)
   * [CLI Haste client](https://github.com/jirutka/haste-client) written in Python
* **www-apps/haste-server** (0.1.0)
* **www-apps/liferay-portal** (6.1.1)
   * with fixes for OpenJDK
* **www-apps/liferay-portal-bin** (6.1.1)
   * with fixes for OpenJDK
* **www-apps/xwiki-enterprise-bin** (4.5.3, 5.0.3, 5.2-M1, 5.2-M2, 5.2.1, 5.4.1)
* **www-misc/shibboleth-sp** (2.4.3)
   * with FastCGI and Apache support, customized configuration (if you’re not _forced_ to use Shibboleth, please run away… it’s horrible protocol)
* **www-servers/nginx** (1.2.2, 1.4.1)
   * with built-in Passenger module (for ree18 and ruby19), [sticky module](http://code.google.com/p/nginx-sticky-module/), [echo module](https://github.com/agentzh/echo-nginx-module) and customized config
* **www-servers/tomcat** (7.0.32, 7.0.42)
   * customized Tomcat ebuild with improved tomcat-instances manager, config files, JMX and log4j support

Feel free to contribute!


Using with Layman
-----------------

Use layman to easily install and update overlays over time.

If you haven’t used layman yet, just run these commands:

	USE=git emerge -va layman
	echo PORTDIR_OVERLAY=\"\" > /var/lib/layman/make.conf
	echo "source /var/lib/layman/make.conf" >> /etc/make.conf


Then you can add this overlay wih:

	layman -o https://raw.github.com/cvut/gentoo-overlay/master/overlay.xml -f -a cvut

Keep the overlay up to date from Git:

	layman -s cvut


Maintainers
-----------

* [Jakub Jirutka](mailto:jirutjak@fit.cvut.cz)
