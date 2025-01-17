################################################################################
#
# civetweb
#
################################################################################

CIVETWEB_VERSION = 4245a37b436da23e1e148fd35513732169f80b11
CIVETWEB_SITE = https://github.com/civetweb/civetweb
CIVETWEB_SITE_METHOD = git
CIVETWEB_LICENSE = MIT
CIVETWEB_LICENSE_FILES = LICENSE.md
CIVETWEB_CPE_ID_VENDOR = civetweb_project

CIVETWEB_CONF_OPTS = TARGET_OS=LINUX WITH_IPV6=1 \
	$(if $(BR2_INSTALL_LIBSTDCPP),WITH_CPP=1)
CIVETWEB_COPT = -DHAVE_POSIX_FALLOCATE=0
CIVETWEB_LIBS = -lpthread -lm
CIVETWEB_SYSCONFDIR = /etc
CIVETWEB_HTMLDIR = /var/www
CIVETWEB_INSTALL_OPTS = \
	DOCUMENT_ROOT="$(CIVETWEB_HTMLDIR)" \
	CONFIG_FILE2="$(CIVETWEB_SYSCONFDIR)/civetweb.conf" \
	HTMLDIR="$(TARGET_DIR)$(CIVETWEB_HTMLDIR)" \
	SYSCONFDIR="$(TARGET_DIR)$(CIVETWEB_SYSCONFDIR)"

ifeq ($(BR2_TOOLCHAIN_HAS_SYNC_4),)
CIVETWEB_COPT += -DNO_ATOMICS=1
endif

ifeq ($(BR2_PACKAGE_LUAJIT),y)
CIVETWEB_CONF_OPTS += WITH_LUAJIT_SHARED=1
CIVETWEB_LIBS += `$(PKG_CONFIG_HOST_BINARY) --libs luajit` -ldl
CIVETWEB_DEPENDENCIES += host-pkgconf luajit
else ifeq ($(BR2_PACKAGE_LUA):$(BR2_STATIC_LIBS),y:)
CIVETWEB_CONF_OPTS += WITH_LUA=1 WITH_LUA_SHARED=1 LUA_SHARED_LIB_FLAG=''
CIVETWEB_LIBS += `$(PKG_CONFIG_HOST_BINARY) --libs lua`
CIVETWEB_DEPENDENCIES += host-pkgconf lua
ifeq ($(BR2_PACKAGE_LUA_5_1),y)
CIVETWEB_CONF_OPTS += WITH_LUA_VERSION=501
else ifeq ($(BR2_PACKAGE_LUA_5_3),y)
CIVETWEB_CONF_OPTS += WITH_LUA_VERSION=503
else ifeq ($(BR2_PACKAGE_LUA_5_4),y)
CIVETWEB_CONF_OPTS += WITH_LUA_VERSION=504
endif
endif

ifeq ($(BR2_PACKAGE_OPENSSL),y)
CIVETWEB_COPT += -DNO_SSL_DL
CIVETWEB_LIBS += `$(PKG_CONFIG_HOST_BINARY) --libs openssl`
CIVETWEB_DEPENDENCIES += openssl host-pkgconf
else
CIVETWEB_COPT += -DNO_SSL
endif

ifeq ($(BR2_PACKAGE_ZLIB),y)
CIVETWEB_CONF_OPTS += WITH_ZLIB=1
CIVETWEB_LIBS += -lz
CIVETWEB_DEPENDENCIES += zlib
endif

ifeq ($(BR2_PACKAGE_CIVETWEB_SERVER),y)
CIVETWEB_BUILD_TARGETS += build
CIVETWEB_INSTALL_TARGETS += install
endif

ifeq ($(BR2_PACKAGE_CIVETWEB_LIB),y)
CIVETWEB_INSTALL_STAGING = YES
CIVETWEB_INSTALL_TARGETS += install-headers

ifeq ($(BR2_STATIC_LIBS)$(BR2_SHARED_STATIC_LIBS),y)
CIVETWEB_BUILD_TARGETS += lib
CIVETWEB_INSTALL_TARGETS += install-lib
endif

ifeq ($(BR2_SHARED_LIBS)$(BR2_SHARED_STATIC_LIBS),y)
CIVETWEB_BUILD_TARGETS += slib
CIVETWEB_INSTALL_TARGETS += install-slib
endif

endif # BR2_PACKAGE_CIVETWEB_LIB

define CIVETWEB_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) $(CIVETWEB_BUILD_TARGETS) \
		$(CIVETWEB_CONF_OPTS) \
		COPT="$(CIVETWEB_COPT)" LIBS="$(CIVETWEB_LIBS)"
endef

define CIVETWEB_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/include
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) $(CIVETWEB_INSTALL_TARGETS) \
		PREFIX="$(STAGING_DIR)/usr" \
		$(CIVETWEB_INSTALL_OPTS) \
		$(CIVETWEB_CONF_OPTS) \
		COPT='$(CIVETWEB_COPT)'
endef

define CIVETWEB_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/include
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) $(CIVETWEB_INSTALL_TARGETS) \
		PREFIX="$(TARGET_DIR)/usr" \
		$(CIVETWEB_INSTALL_OPTS) \
		$(CIVETWEB_CONF_OPTS) \
		COPT='$(CIVETWEB_COPT)'
endef

$(eval $(generic-package))
