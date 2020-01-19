include $(THEOS)/makefiles/common.mk

FINALPACKAGE=1

export TARGET = iphone:clang:11.2:11.0

ARCHS = arm64 arm64e

TWEAK_NAME = SnapShot

SnapShot_FILES = Tweak.xm
SnapShot_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "sbreload"
