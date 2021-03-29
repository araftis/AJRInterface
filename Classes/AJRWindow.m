/*
AJRWindow.m
AJRInterface

Copyright © 2021, AJ Raftis and AJRFoundation authors
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, 
  this list of conditions and the following disclaimer in the documentation 
  and/or other materials provided with the distribution.
* Neither the name of AJRFoundation nor the names of its contributors may be 
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

#import "AJRWindow.h"

#import <AJRFoundation/AJRFoundation.h>

typedef struct {
    NSInteger key;
    NSInteger modifiers;
    NSInteger retainCount;
} AJRKeyEventKey;

static AJRKeyEventKey *AJRCreateEventKey(NSInteger keyCode, NSInteger modifiers) {
    AJRKeyEventKey *newKey = (AJRKeyEventKey *)NSZoneMalloc(NULL, sizeof(AJRKeyEventKey));
    newKey->key = keyCode;
    newKey->modifiers = modifiers;
    newKey->retainCount = 0;
    return newKey;
}

static NSString * _Nullable AJRDescribeKeyEventKey(NSMapTable * _Nonnull __strong *table, const AJRKeyEventKey *entry) {
    return AJRFormat(@"<AJRKeyEventKey: key: %ld, modifiers: %ld, retainCount: %ld>", (long)entry->key, (long)entry->modifiers, (long)entry->retainCount);
}

static unsigned long AJRHashKeyEventKey(NSMapTable *table, const AJRKeyEventKey *entry) {
    return [@(entry->key) hash] ^ [@(entry->modifiers) hash];
}

static BOOL AJREqualKeyEventKey(NSMapTable *table, const AJRKeyEventKey *left, const AJRKeyEventKey *right) {
    return left->key == right->key && left->modifiers == right->modifiers;
}

static void AJRRetainKeyEventKey(NSMapTable *table, AJRKeyEventKey *entry) {
    entry->retainCount += 1;
}

static void AJRReleaseKeyEventKey(NSMapTable *table, AJRKeyEventKey *entry) {
    if (entry->retainCount == 1) {
        NSZoneFree(NULL, entry);
    } else if (entry->retainCount > 0) {
        entry->retainCount -= 1;
    }
}

@implementation AJRWindow {
    NSMutableDictionary<NSString *, id> *_actionsToReceivers;
    NSMapTable *_keysToReceivers;
}

- (NSMapTable *)keysToReceivers {
    if (_keysToReceivers == nil) {
        NSMapTableKeyCallBacks callbacks;
        
        callbacks.hash = (void *)AJRHashKeyEventKey;
        callbacks.isEqual = (void *)AJREqualKeyEventKey;
        callbacks.retain = (void *)AJRRetainKeyEventKey;
        callbacks.release = (void *)AJRReleaseKeyEventKey;
        callbacks.describe = (void *)AJRDescribeKeyEventKey;
        
        _keysToReceivers = NSCreateMapTable(callbacks, NSObjectMapValueCallBacks, 0);
    }
    return _keysToReceivers;
}

- (void)addKeyBypassTo:(id)receiver forKeyCode:(NSInteger)keyCode withModifiers:(NSEventModifierFlags)modifiers {
    NSMapInsert([self keysToReceivers], AJRCreateEventKey(keyCode, modifiers), (__bridge void *)receiver);
}

- (void)removeKeyBypassForKeyCode:(NSInteger)key withModifiers:(NSEventModifierFlags)modifiers {
    AJRKeyEventKey eventKey = { key, modifiers };
    
    NSMapRemove([self keysToReceivers], &eventKey);
}

- (void)addTargetBypassTo:(id)receiver forAction:(SEL)action {
    if (_actionsToReceivers == nil) {
        _actionsToReceivers = [NSMutableDictionary dictionary];
    }
    _actionsToReceivers[NSStringFromSelector(action)] = receiver;
}

- (void)removeTargetBypassForAction:(SEL)action {
    [_actionsToReceivers removeObjectForKey:NSStringFromSelector(action)];
}

- (void)sendEvent:(NSEvent *)anEvent {
    if ([anEvent type] == NSEventTypeKeyDown) {
        if ([[self delegate] respondsToSelector:@selector(keyDownInWindow:)]) {
            if ([(id <AJRKeyDispatchWindow>)[self delegate] keyDownInWindow:anEvent]) {
                return;
            }
        }
        
        AJRKeyEventKey key = { [anEvent keyCode], [anEvent modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask, -1};
        id possibleReceiver = (__bridge id)NSMapGet([self keysToReceivers], &key);
        if (possibleReceiver && [possibleReceiver respondsToSelector:@selector(keyDownInWindow:)]) {
            if ([possibleReceiver keyDownInWindow:anEvent]) {
                return;
            }
        }
    }
    [super sendEvent:anEvent];
}

- (id)targetBypassForAction:(SEL)action defaultTarget:(id)defaultTarget {
    return [_actionsToReceivers objectForKey:NSStringFromSelector(action)] ?: defaultTarget;
}

typedef void (*AJRActionImp)(id, SEL, id);

- (BOOL)tryToPerform:(SEL)action with:(id)object {
    id bypassTarget = [_actionsToReceivers objectForKey:NSStringFromSelector(action)];
    if (bypassTarget) {
        AJRActionImp imp = (AJRActionImp)[bypassTarget methodForSelector:action];
        if (imp) {
            imp(bypassTarget, action, object);
            return YES;
        }
    }
    return [super tryToPerform:action with:object];
}

@end
