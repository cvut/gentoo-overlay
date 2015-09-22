CVUT Gentoo overlay
===================

Gentoo overlay with some ebuilds created or modified on [CTU](http://www.cvut.cz/) and are not yet in the official repository.


List of ebuilds
---------------

* **app-backup/prebackup** (0.1.0, 0.2.0, 0.3.0, 0.4.0)
* **app-crypt/easy-rsa** (2.2.0, 3.0.0\_rc2)
   * 2.2.0 with patch for [subjectAltName](http://www.msquared.id.au/articles/easy-rsa-subjectaltname/)
* **app-emulation/lxc** (1.0.7, 1.1.3)
* **app-misc/alfresco-bin** (4.2.b, 4.2d)
   * with Share, GoogleDocs integration, SOLR server
* **app-misc/alfresco-solr-bin** (4.2.b)
* **app-misc/apache-servicemix-bin** (4.5.1)
* **app-misc/openidm** (2.1.0)
* **dev-db/mongodb (2.4.6)**
   * with patch for [SERVER-9248](https://jira.mongodb.org/browse/SERVER-9248)
* **dev-java/artifactory-bin** (2.6.6)
* **dev-java/hikaricp-bin** (2.0.1)
* **dev-java/jboss-as-bin** (7.1)
   * binary package, standalone mode only, proper init script included!
* **dev-java/jdbc-mysql-bin** (5.1.18)
   * jdbc-mysql can’t be built on JDK 7, so there’s a binary package…
* **dev-java/jdbc-oracle-bin** (12.1)
* **dev-java/maven-bin** (3.2.3)
* **dev-java/rhino** (1.7R4)
* **dev-libs/opensaml** (2.4.3)
   * dependency for shibboleth-sp
* **dev-libs/xmltooling-c** (1.4.2)
   * dependency for shibboleth-sp
* **dev-lua/luaexpat** (1.3.0)
* **dev-lua/lualdap** (git)
* **dev-lua/lua-resty-http** (0.05, 0.06)
* **dev-util/activiti-bin** (5.14, 5.15.1)
* **dev-util/sonar-bin** (3.7)
   * proper ebuild, much better than godin’s :)
* **dev-vcs/gitlab-shell** (1.7.1, 1.8.0, 2.4.2)
* **mail-mta/mailcatcher** (0.5.12)
   * [mailcatcher](https://github.com/sj26/mailcatcher) with [persist patch](https://github.com/sj26/mailcatcher/pull/109) and removed exit button, intended for a standalone usage, init script included
* **mail-mta/opensmtpd**
* **mail-mta/opensmtpd-extras**
* **media-gfx/swftools** (0.9.2)
   * with enabled pdf2swf without poppler (see [#412423](https://bugs.gentoo.org/show_bug.cgi?id=412423))
* **net-im/openfire** (3.8.1)
* **net-im/prosody** (0.9.4, 0.9.7)
   * with [mod_auth_ldap](https://code.google.com/p/prosody-modules/wiki/mod_auth_ldap), [mod_carbons](http://code.google.com/p/prosody-modules/wiki/mod_carbons) and [mod_smacks](http://code.google.com/p/prosody-modules/wiki/mod_smacks)
* **net-misc/minidlna** (1.0.24)
   * with improved ebuild and init script
* **sys-apps/shadow** (4.2.1)
   * with patch [884895a](https://github.com/shadow-maint/shadow/commit/884895ae25f4e684b8ca75ac03e775370f43a63d)
* **sys-auth/ssh-ldap-pubkey** (0.2.1, 0.2.2, 0.2.3, 0.3.2, 0.4.0)
   * with some fixes and enhacements
* **www-apps/haste-client** (1.0, 1.0.1, 1.0.2)
   * [CLI Haste client](https://github.com/jirutka/haste-client) written in Python
* **www-apps/haste-server** (0.1.0)
* **www-apps/liferay-portal** (6.1.1, 6.1.2, 6.2.1)
   * with fixes for OpenJDK; if you’re not crazy masochist, run away from Liferay!
* **www-apps/liferay-portal-bin** (6.1.1, 6.2.1)
   * with fixes for OpenJDK; if you’re not crazy masochist, run away from Liferay!
* **www-apps/xwiki-enterprise-bin** (4.5.3, 5.0.3, 5.2-M1, 5.2-M2, 5.2.1, 5.4.1)
* **www-misc/shibboleth-sp** (2.4.3)
   * with FastCGI and Apache support, customized configuration (if you’re not _forced_ to use Shibboleth, please run away… it’s horrible protocol)
* **www-servers/jetty-runner** (9.2.3, 9.3.0)
* **www-servers/tomcat** (7.0.32, 7.0.42, 7.0.56)

Feel free to contribute!


Usage
-----

Note: Starting with sys-apps/portage-2.2.16, Portage now has a new modular plug-in [sync system](https://wiki.gentoo.org/wiki/Project:Portage/Sync).
This makes Layman and other similar tools unnecessary for managing overlays like this one.

1. Prepare location for the overlay, e.g. `/usr/local/portage/cvut`:

   ```sh
   mkdir -p /usr/local/portage/cvut
   ```

2. Create file `/etc/portage/repos.conf/cvut.conf`:

   ```ini
   [cvut]
   location = /usr/local/portage/cvut
   sync-type = git
   sync-uri = git://github.com/cvut/gentoo-overlay
   auto-sync = yes
   ```

3. Synchronize repository:

   ```sh
   emerge --sync cvut
   eix-update  # run only if you use eix
   ```

Overlay will be automatically synchronized when running `emerge --sync` or `eix-sync`.


Notes
-----

We are not maintaining ebuild for GitLab anymore, its new home is in the [fritteli’s overlay](https://github.com/fritteli/gentoo-overlay).
If you’re using Ansible, then you might be interested in [Ansible role for GitLab](https://github.com/jirutka/ansible-role-gitlab) instead.


Maintainers
-----------

* [Jakub Jirutka](mailto:jirutjak@fit.cvut.cz)
