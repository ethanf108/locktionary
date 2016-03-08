ARCHS = armv7 arm64

TARGET = iphone:clang:latest:5.0

export THEOS=/var/theos

include $(THEOS)/makefiles/common.mk


TWEAK_NAME = locktionary
locktionary_FILES = Tweak.xm
locktionary_CFLAGS = -fobjc-arc
locktionary_FRAMEWORKS = Foundation UIKit
locktionary_CODESIGN_FLAGS = -S
locktionary_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/aggregate.mk

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
