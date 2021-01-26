/*!
 @header AJRStorefrontItem.h

 @author Alex Raftis
 @updated 2/6/09.
 @copyright 2009 Apple, Inc.. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <Cocoa/Cocoa.h>

/*!
 @class AJRStorefrontItem
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface AJRStorefrontItem : NSCollectionViewItem 
{
    NSView            *_primaryView;
    NSView            *_alternateView;
    NSButton        *_toggleFavoritesButton;
    
    BOOL            _selected;
    BOOL            _isRegistered;
    NSColor            *_textColor;
}

@property (nonatomic,retain) IBOutlet NSView *alternateView;
@property (nonatomic,retain) IBOutlet NSButton *toggleFavoritesButton;
@property (nonatomic,retain) NSColor *textColor;

- (IBAction)toggleSettings:(id)sender;
- (IBAction)toggleFavorites:(id)sender;

@end
