
#import "AJRColorTransformer.h"

#import <AJRInterface/AJRInterface.h>

@implementation AJRColorTransformer

+ (void)load {
	AJRColorTransformer	*transformer = [[self alloc] init];
	[NSValueTransformer setValueTransformer:transformer forName:@"AJRColorTransformer"];
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSColor class];
}

- (id)transformedValue:(id)value {
	return AJRColorFromString(value);
}

- (id)reverseTransformedValue:(id)value {
	return AJRStringFromColor(value);
}

@end
