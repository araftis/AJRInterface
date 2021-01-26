
#import "NSApplication+Extensions.h"

#import "AJRBorder.h"
#import "AJRDropShadowBorder.h"
#import "AJRExceptionPanel.h"
#import "AJRImages.h"
#import "AJRImageFormat.h"
#import "AJRImageSaveAccessory.h"
#import "AJRWindow.h"
#import "NSAlert+Extensions.h"

#import <AJRFoundation/AJRFoundation.h>
#import <AJRInterface/AJRInterface-Swift.h>
#import <objc/runtime.h>

static BOOL AJR_UNUSED _graphicalExceptions = YES;

NSString *NSApplicationWillAbnormallyTerminateNotification = @"NSApplicationWillAbnormallyTerminateNotification";
NSString *AJRApplicationExceptionKey = @"AJRApplicationExceptionKey";

@interface NSApplication (AJRForwardDelcarations)
- (void)ajr_sendEvent:(NSEvent *)event;
- (id)ajr_targetForAction:(SEL)action to:(id)target from:(id)sender;
- (BOOL)ajr_sendAction:(SEL)action to:(id)target from:(id)sender;
+ (id)ajr_sharedApplication;
@end

// Used to bootstrap some AJRFoundation code into place.
@interface AJRApplicationInitializer : NSObject

@end

@implementation AJRApplicationInitializer

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = objc_getClass("NSApplication");
        AJRSwizzleMethods(class, @selector(sendEvent:), class, @selector(ajr_sendEvent:));
        // These two swizzles deal with integrating with the AJRWindow so that we can forcibly reroute responder chain dispatch.
        AJRSwizzleMethods(class, @selector(targetForAction:to:from:), class, @selector(ajr_targetForAction:to:from:));
        AJRSwizzleMethods(class, @selector(sendAction:to:from:), class, @selector(ajr_sendAction:to:from:));
        AJRSwizzleClassMethods(class, @selector(sharedApplication), class, @selector(ajr_sharedApplication));

        // Just because this is a descent place to put this.
        AJRRegisterPluinTransformer(@"image", ^id _Nullable(NSString *rawValue, NSBundle *bundle, NSError **error) {
            return [AJRImages imageNamed:rawValue inBundle:bundle];
        });
        AJRRegisterPluinTransformer(@"cursor", ^id _Nullable(NSString *rawValue, NSBundle *bundle, NSError **error) {
            NSArray *parts = [rawValue componentsSeparatedByString:@":"];
            NSError *localError = nil;
            NSCursor *cursor = nil;

            if (parts.count == 2) {
                NSImage *image = [AJRImages imageNamed:parts[0] inBundle:bundle];
                if (image == nil) {
                    localError = [NSError errorWithDomain:AJRPlugInManagerErrorDomain format:@"Failed to find image \"%@\" in bundle: %@", parts[0], bundle];
                } else {
                    NSPoint offset = NSPointFromString(parts[1]);
                    cursor = [[NSCursor alloc] initWithImage:image hotSpot:offset];
                }
            } else {
                localError = [NSError errorWithDomain:AJRPlugInManagerErrorDomain message:@"cursor types should be in the format \"<cursor_name>:{<x_offset>,<y_offset>}\""];
            }

            return AJRAssertOrPropagateError(cursor, error, localError);
        });
    });
}

@end

@implementation NSApplication (AJRInterfaceExtensions)

- (void)snapshotAndSaveWindow:(NSWindow *)window {
	NSView *view = [[window contentView] superview];
	NSBitmapImageRep *bitmap;
	NSImage *image;
	
	if (view) {
		NSSavePanel *savePanel;
		NSString *path;
		AJRImageSaveAccessory *accessory;
		NSSize size;
		AJRBorder *border;
		NSURL *directory;
		
		window = [self keyWindow];
		[view cacheDisplayInRect:[view bounds] toBitmapImageRep:bitmap];
		size = [view bounds].size;
		border = [AJRBorder borderForName:@"Drop Shadow"];
		[(AJRDropShadowBorder *)border setClip:NO];
		image = [[NSImage alloc] initWithSize:(NSSize){size.width + 20.0, size.height + 20.0}];
		[image lockFocus];
		[border drawBorderInRect:(NSRect){{0.0, 0.0}, [image size]} controlView:nil];
		[border drawBorderInRect:(NSRect){{0.0, 0.0}, [image size]} controlView:nil];
		[bitmap drawInRect:(NSRect){{10.0, 13.0}, size}];
		[image unlockFocus];
		
		savePanel = [NSSavePanel savePanel];
		accessory = [[AJRImageSaveAccessory alloc] initWithSavePanel:savePanel];
		if ([[window title] length]) {
			path = [window title];
		} else {
			path = @"Untitled";
		}
		path = [path stringByAppendingPathExtension:[[accessory currentImageFormat] extension]];
		
		directory = [[NSUserDefaults standardUserDefaults] URLForKey:@"AJRExportWindowPath"];
		if (!directory) directory = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
		[savePanel setAllowedFileTypes:[NSArray arrayWithObject:[[accessory currentImageFormat] extension]]];
		[savePanel setCanSelectHiddenExtension:YES];
		[savePanel setAccessoryView:[accessory view]];
		[savePanel setDirectoryURL:directory];
		[savePanel setNameFieldStringValue:[path lastPathComponent]];
		[savePanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
			if (result == NSModalResponseOK) {
				NSData *data;
				
				[[NSUserDefaults standardUserDefaults] setObject:[savePanel URL] forKey:@"AJRExportWindowPath"];
				
				data = [accessory representationForImage:image];
				if (data) {
					[data writeToURL:[savePanel URL] atomically:NO];
				} else {
					AJRBeginAlertPanel(NSAlertStyleWarning, @"Unable to produce bitmap data for image, please try saving in a different image format.", nil, nil, nil, nil, nil);
				}
			}
		}];
	}
}

- (void)snapshotAndSaveWindowAsPDF:(NSWindow *)window {
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	NSURL *directory = [[NSUserDefaults standardUserDefaults] URLForKey:@"AJRExportWindowPath"];
	
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];
	[savePanel setCanSelectHiddenExtension:YES];
	[savePanel setDirectoryURL:directory];
	[savePanel setNameFieldStringValue:[[window title] lastPathComponent]];
	[savePanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
		if (result == NSModalResponseOK) {
			NSData *data = [window dataWithPDFInsideRect:(NSRect){NSZeroPoint, [[self keyWindow] frame].size}];
			NSError *error;
			
			[[NSUserDefaults standardUserDefaults] setURL:[savePanel directoryURL] forKey:@"AJRExportWindowPath"];
			
			if (![data writeToURL:[savePanel URL] options:NSAtomicWrite error:&error]) {
				AJRBeginAlertPanel(NSAlertStyleCritical, AJRFormat(@"Unable to save file %@: %@", [[savePanel URL] lastPathComponent], [error localizedDescription]), @"OK", nil, nil, nil, NULL);
			}
		}
	}];
}

- (void)ajr_sendEvent:(NSEvent *)event {
    if ([event type] == NSEventTypeKeyDown) {
        // Basically, cmd-alt-f1
        if ([[event characters] length] > 0 && [[event characters] characterAtIndex:0] == 0xf704 &&
            ([event modifierFlags] & (NSEventModifierFlagCommand | NSEventModifierFlagOption | NSEventModifierFlagFunction))) {
			[self snapshotAndSaveWindow:[self keyWindow]];
        } else if ([[event characters] length] > 0 && [[event characters] characterAtIndex:0] == 0xf705 &&
                    ([event modifierFlags] & (NSEventModifierFlagCommand | NSEventModifierFlagOption | NSEventModifierFlagFunction))) {
			[self snapshotAndSaveWindowAsPDF:[self keyWindow]];
        }
    }
    [self ajr_sendEvent:event];
}

- (id)targetBypassForAction:(SEL)action defaultTarget:(nullable id)defaultTarget {
	id foundTarget = defaultTarget;
	
	if (foundTarget == nil || [foundTarget respondsToSelector:@selector(window)]) {
		NSWindow *possibleWindow = foundTarget == nil ? [NSApp keyWindow] : [(NSView *)foundTarget window];
		AJRWindow *foundWindow = AJRObjectIfKindOfClass(possibleWindow, AJRWindow);
		if (foundWindow) {
			foundTarget = [foundWindow targetBypassForAction:action defaultTarget:foundTarget];
		}
	}
	
	return foundTarget;
}

- (id)ajr_targetForAction:(SEL)action to:(id)target from:(id)sender {
	return [self targetBypassForAction:action defaultTarget:[self ajr_targetForAction:action to:target from:sender]];
}

- (BOOL)ajr_sendAction:(SEL)action to:(id)target from:(id)sender {
	return [self ajr_sendAction:action to:[self targetBypassForAction:action defaultTarget:target] from:sender];
}

+ (id)ajr_sharedApplication {
	id result = [self ajr_sharedApplication];
	[AJRInterfaceBootstrap bootstrap];
	[AJRPlugInManager sharedPlugInManager];
	return result;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
#warning fix this.
//- (void)reportException:(NSException *)theException {
//    AJRLogError(@"Uncaught Exception: %@\n", theException/*, GTMStackTraceFromException(theException, NO)*/);
//
//    if (_graphicalExceptions) {
//        AJRExceptionPanel    *panel = [[AJRExceptionPanel alloc] initWithException:theException];
//        if ([panel run] == NSAlertFirstButtonReturn) {
//            id delegate = [self delegate];
//
//            if (delegate && [delegate respondsToSelector:@selector(application:willAbnormallyTerminateWithException:)]) {
//                [delegate application:self willAbnormallyTerminateWithException:theException];
//            }
//            [NSApp criticallyTerminateWithException:theException];
//        }
//    }
//}
#pragma clang diagnostic pop

- (NSInteger)runFixedModalForWindow:(NSWindow *)theWindow {
    NSEvent *originalEvent = [NSApp currentEvent];
    NSEvent *fakeEvent = nil;
    NSInteger modalReturn;
    NSWindow *keyWindow = [NSApp keyWindow];
    
    if ([originalEvent type] == NSEventTypeLeftMouseDown) {
        fakeEvent = [NSEvent mouseEventWithType:NSEventTypeLeftMouseUp location:[originalEvent locationInWindow] modifierFlags:[originalEvent modifierFlags] timestamp:[originalEvent timestamp] windowNumber:[originalEvent windowNumber] context:[NSGraphicsContext currentContext] eventNumber:[originalEvent eventNumber] + 1 clickCount:[originalEvent clickCount] pressure:0.0];
    }
    modalReturn = [self runModalForWindow:theWindow];
    if (fakeEvent) {
        [keyWindow postEvent:fakeEvent atStart:YES];
    } else {
        [NSApp _setCurrentEvent:originalEvent];
    }
    return modalReturn;
}

- (void)criticallyTerminateWithException:(NSException *)exception {
    [NSApp setDelegate:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NSApplicationWillAbnormallyTerminateNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:exception, AJRApplicationExceptionKey, nil]];
    
    exit(1);
}

@end
