export THEOS=/var/theos
ARCHS = armv7 arm64
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = locktionary
locktionary_FILES = Tweak.xm
locktionary_FRAMEWORKS = UIKit
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
