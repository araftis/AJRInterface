
#import <AJRInterface/AJRInspectorModule.h>

@class AJRBorder, AJRBorderInspectorModule;

@interface AJRBorderInspector : NSBox
{
    AJRBorder                *border;
    NSMutableDictionary        *inspectorModules;
    AJRBorderInspectorModule    *inspectorModule;
    NSMutableDictionary        *dictionary;
}

- (void)setBorder:(AJRBorder *)aBorder;
- (AJRBorder *)border;

@end
