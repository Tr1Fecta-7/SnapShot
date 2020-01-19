FINALPACKAGE=1
export TARGET = iphone:clang:11.2:11.0

include $(THEOS)/makefiles/common.mk


ARCHS = arm64 arm64e

TWEAK_NAME = SnapShot

SnapShot_FILES = Tweak.xm IAScreenCaptureView.m
SnapShot_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
SnapShot_FRAMEWORKS = AssetsLibrary AVFoundation CoreGraphics CoreMedia CoreVideo QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "sbreload"
