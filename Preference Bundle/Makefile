export THEOS=/var/theos
ARCHS= armv7 arm64
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = loctionaryPrefs
loctionaryPrefs_FILES = hndRootListController.m
loctionaryPrefs_INSTALL_PATH = /Library/PreferenceBundles
loctionaryPrefs_FRAMEWORKS = UIKit
loctionaryPrefs_PRIVATE_FRAMEWORKS = Preferences
locktionaryPrefs_LDFLAGS += -Wl,-segalign,4000
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/loctionaryPrefs.plist$(ECHO_END)
