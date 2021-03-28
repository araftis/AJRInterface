
#import "AJRPopUpTextField.h"

#import "AJRPopUpTextFieldCell.h"

@implementation AJRPopUpTextField

#pragma mark Initialization

- (void)_completeInit {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeActive:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeActive:) name:NSApplicationDidResignActiveNotification object:NSApp];
}

#pragma mark Creation

- (id)initWithFrame:(NSRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self _completeInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super initWithCoder:coder])) {
		[self _completeInit];
	}
	return self;
}

#pragma mark Destruction

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Properties

- (void)setMenu:(NSMenu *)menu {
	[(AJRPopUpTextFieldCell *)[self cell] setMenu:menu];
	[self setNeedsDisplay:YES];
}

- (NSMenu *)menu {
	return [(AJRPopUpTextFieldCell *)[self cell] menu];
}

#pragma mark NSView

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
	if ([self window]) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:[self window]];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:[self window]];
	}
}

- (void)viewDidMoveToWindow {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeActive:) name:NSWindowDidBecomeKeyNotification object:[self window]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeActive:) name:NSWindowDidResignKeyNotification object:[self window]];
}

- (void)viewDidChangeEffectiveAppearance {
    [[self cell] viewDidChangeEffectiveAppearance];
}

#pragma mark Notifications (NSApp)

- (void)applicationDidChangeActive:(NSNotification *)notification {
	[self setNeedsDisplay:YES];
}

@end
