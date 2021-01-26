
#import <AppKit/AppKit.h>

#define AJRContentNoScalingMask        0x00
#define AJRContentScaledMask            0x01
#define AJRContentScaledToFitMask    0x02
#define AJRContentScaledPorportional    0x04

extern NSRect AJRComputeScaledRect(NSRect rect, NSSize naturalSize, NSUInteger mask);

extern NSBundle *AJRInterfaceBundle(void);
