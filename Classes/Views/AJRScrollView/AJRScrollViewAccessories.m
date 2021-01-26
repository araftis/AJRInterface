
#import "AJRScrollViewAccessories.h"

#import "NSBundle+Extensions.h"

#import <math.h>

#define EXPONENT ((double)2.66)

@implementation AJRScrollViewAccessories

static AJRScrollViewAccessories *SELF = nil;

+ (id)allocWithZone:(NSZone *)zone
{
    if (SELF == nil) {
        SELF = [super allocWithZone:zone];
    }
    return SELF;
}

+ (id)sharedInstance
{
    return [[self alloc] init];
}

- (void)awakeFromNib
{
   [textField setFont:[NSFont userFontOfSize:10.0]];
}

- (NSInteger)runWithPercent:(NSInteger)percent
{
   NSInteger        result;
   
   if (!window) {
      [NSBundle ajr_loadNibNamed:@"AJRScrollViewAccessories" owner:self];

      [slider setMinValue:(double)pow((double)10.0, (double)1.0 / EXPONENT)];
      [slider setMaxValue:(double)pow((double)1600.0, (double)1.0 / EXPONENT)];
   }

   [textField setIntegerValue:percent];
   [slider setDoubleValue:(double)pow((double)percent, (double)1.0 / EXPONENT)];

   [window center];
   [window makeKeyAndOrderFront:self];

   result = [NSApp runModalForWindow:window];
   
   [window orderOut:self];

   return result;
}

- (void)takeIntValueFrom:(id)sender
{
   NSInteger        percent = rint(pow([sender floatValue], EXPONENT));

   if (percent < 100) {
      percent = (percent / 5) * 5;
   } else if (percent < 250) {
      percent = (percent / 25) * 25;
   } else if (percent < 500) {
      percent = (percent / 50) * 50;
   } else {
      percent = (percent / 100) * 100;
   }

   [textField setIntegerValue:percent];
}

- (void)ok:sender
{
   [NSApp stopModalWithCode:NSModalResponseOK];
}

- (void)cancel:sender
{
   [NSApp stopModalWithCode:NSModalResponseCancel];
}

- (NSInteger)percent
{
   return [textField floatValue];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
   double        value = [textField doubleValue];

   if (value < 10.0) value = 10.0;
   if (value > 1600.0) value = 1600.0;

   [slider setDoubleValue:(double)pow(value, (double)1.0 / EXPONENT)];
}

@end
