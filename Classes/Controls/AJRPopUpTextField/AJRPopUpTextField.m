/*
 AJRPopUpTextField.m
 AJRInterface

 Copyright © 2022, AJ Raftis and AJRInterface authors
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of AJRInterface nor the names of its contributors may be
   used to endorse or promote products derived from this software without
   specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL AJ RAFTIS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
