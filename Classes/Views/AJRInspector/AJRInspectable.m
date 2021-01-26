//
//  AJRInspectable.m
//  AJRInterface
//
//  Created by AJ Raftis on 4/4/19.
//

#import "AJRInspectable.h"

#import <AJRFoundation/AJRFoundation.h>

AJRInspectorIdentifier const AJRInspectorIdentifierNone = @"No Inspector";
AJRInspectorIdentifier const AJRInspectorContentIdentifierAny = @"any";

@implementation NSObject (AJRInspectable)

- (NSArray<AJRInspectorIdentifier> *)inspectorIdentifiers {
    return @[];
}

@end
