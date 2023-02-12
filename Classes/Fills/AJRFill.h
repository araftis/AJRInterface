/*
 AJRFill.h
 AJRInterface

 Copyright © 2023, AJ Raftis and AJRInterface authors
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

/*!
 @header AJRFill.h
 @discussion Contains AJRFill and related constants
 */
#import <AppKit/AppKit.h>

/*!
 @discussion Identifies the notification sent when a fill has just changed one of its properties.
 */
extern NSString *AJRFillDidUpdateNotification;

/*!
 @discussion Identifies the notification sent just prior to a fill changing one of its properties.
 */
extern NSString *AJRFillWillUpdateNotification;

/*!
 @abstract The Factory and superclass of all fill classes.
 @discussion This class is used as both the factory for getting instances of fills, but is also the common superclass of all fills in the system. You can use fills to fill either rectangles or paths when drawing. Some of our classes use fills to provide a nice, generic manner in which to identify and perform fills. For example, the AJRBox class uses fills.
 
 When implemented a fill, you generally need to implement three classes in your subclass. At minimum, your class should look like this:
 <PRE>
    + (void)load
    {
        [AJRFill regsiterFill:self];
    }
 
    + (NSString *)name
    {
        return @"My Fill";
    }
 
    - (void)fillPath:(NSBezierPath *)path
    {
        &gt;draw your fill here!&lt;
    }
 </PRE>
 Other than that, you can optionally implement the -fillRect: method if you can draw your fill more quickly knowing you're filling a rectangle. This may or may not be true for your subclass. If it's not true, then you only need to implement the -fillPath: method.
 
 Likewise, when chaging one of your fill's properties, you should call -willUpdate and -didUpdate. For example, say your fill has a color property. You should then implement your -setColor: method as follows:
 <PRE>
    - (void)setColor:(NSString *)color
    {
        if (_color != color) {
            [self willUpdate];
            [_color release];
            _color = [color retain];
            s[self didUpdate];
        }
    }
 </PRE>
 */
@interface AJRFill : NSObject <NSCoding>
{
}

/*!
 @methodgroup Factory
 */

/*!
 @abstract Called by subclasses to register themselves with the factory.
 @discussion In your subclasses, you should implement the +load method, where you should call this method to register your fill with the fill factory. This method can be safely called with no autorelease pool in place. Make sure your subclass implements the +name method as well.
 */
+ (void)registerFill:(Class)aClass;

/*!
 @abstract Implemented by subclasses to provide a human readable version of its name.
 @discussion Your subclasses must implemen this method to return a string that can be used to identify your fill to both the factory system and to end users. Thus, "Solid Fill" is a good name, but "solidFill" is not, since even though this will work, it's not a good, human readable name.
 */
+ (NSString *)name;

/*!
 @abstract Returns the list of all the fill class names.
 @discussion Returns the list of fills registered with the factory. The fills are identified by their class name. You can use the names provided by this method to call fillForType:
 @seealso +fillForType:
 @result The list of class names for registered fills.
 */
+ (NSArray *)fillTypes;

/*!
 @abstract Returns the list of all fills by name.
 @discussion Returns the list of fills registered with teh factory. The fills are identified by their name. You can use the names provided by this method to call fillForName:.
 @seealso +fillForName:
 @result The list of names for registered fills.
 */
+ (NSArray *)fillNames;

/*!
 @abstract Retrieves a fill identified by the fill's class name.
 @discussion Returns the fill identified by the fill's class name. If the class name is not registered with the factory, this method returns nil. Any name returned by the +fillTypes will return a valid fill when passed to this method.
 @param type The class name of the fill to return.
 @result The fill identified by type.
 */
+ (AJRFill *)fillForType:(NSString *)type;

/*!
 @abstract Retrieves a fill identified by the fill's name.
 @discussion Returns the fill identified by the fill's name. If the name is not registered with the factory, this method returns nil. Any name returned by the +fillNames will return a valid fill when passed to this method.
 @param name The name of the fill to return.
 @result The fill identified by name.
 */
+ (AJRFill *)fillForName:(NSString *)name;

/*!
 @methodgroup Updating
 */

/*!
 @abstract Called by subclasses prior to changing a value.
 @discussion You should call this method from your subclasses prior to chaning one of your properties. This method will then post a notification that you're about to change a value. That notification is then used by containing classes to traack changes happening to their fill.
 */
- (void)willUpdate;

/*!
 @abstract Called by subclasses after changing a value.
 @discussion You should call this method from your subclasses just after chaning one of your properties. This method will then post a notification that you've just changed a value. That notification is then used by containing classes to traack changes happening to their fill.
 */
- (void)didUpdate;

/*!
 @methodgroup Drawing
 */

/*!
 @abstract Draws the fill into path.
 @discussion You subclasses should override this method to draw your fill into the bounds supplied path. Note that if you must change the graphics context, you should save and restore the graphics context. For example, if you set the clipping path to path, then you should remove that clipping path prior to exiting your method.
 @param path The path to fill.
 */
- (void)fillPath:(NSBezierPath *)path;

- (void)fillPath:(NSBezierPath *)path controlView:(NSView *)controlView;

/*!
 @abstract Draws the fill into path.
 @discussion You subclasses should override this method to draw your fill into the supplied rectangle. Note that if you must change the graphics context, you should save and restore the graphics context. For example, if you set the clipping path to rect, then you should remove that clipping path prior to exiting your method. By default, this method will call fillPath:, but this method is here if you can draw your fill into a rect in a more optimized manner than the more general fillPath: method.
 @param rect The rectangle to fill.
 */
- (void)fillRect:(NSRect)rect;

- (void)fillRect:(NSRect)rect controlView:(NSView *)controlView;

/*!
 @methodgroup Settings
 */

/*!
 @abstract Returns YES if the fill is fully opaque.
 @discussion Override this method if your subclass is not opaque for some reason. For example, if the fill color has a fractional alpha value, then it not opaque. Classes that contain the fill will use this method to determine if they're opaque. By default, fills are opaque.
 */
- (BOOL)isOpaque;

@end
