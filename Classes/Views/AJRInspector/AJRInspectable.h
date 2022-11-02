/*
 AJRInspectable.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * AJRInspectorContentIdentifier NS_TYPED_EXTENSIBLE_ENUM;
typedef NSString * AJRInspectorIdentifier NS_TYPED_EXTENSIBLE_ENUM;

extern AJRInspectorIdentifier const AJRInspectorIdentifierNone;
extern AJRInspectorIdentifier const AJRInspectorContentIdentifierAny;

@protocol AJRInspectable <NSObject>

/*!
 Some objects may return multiple inspectors. If you're one of those objects, override this method rather than the property above. If you override this method, make sure to call super and include it's inspectors as well. For example, say you have a Graphic object and a subclass of Graphic called Circle. Both have inspectors, but Circle also needs to use Graphic's inspectors. Thus, Circle would override this property, call super, and then add it's own inspectors to the array. Additional inspectors should be added to the end of the array.

 By default, this just returns super's contents as well as inspectorIdentifier, assuming inspectorIdentifier doesn't return AJRInspectorIdentifierNone.

 This method may return an empty array, but not nil.

 @return An array of AJRInspectorIdentifiers or an empty array.
 */
@property (nonatomic,readonly) NSArray<AJRInspectorIdentifier> *inspectorIdentifiers;

@end

@interface NSObject (AJRInspectable) <AJRInspectable>

@end

NS_ASSUME_NONNULL_END
