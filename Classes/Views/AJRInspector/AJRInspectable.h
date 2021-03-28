
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
