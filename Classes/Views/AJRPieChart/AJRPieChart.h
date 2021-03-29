/*
AJRPieChart.h
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

#import <Cocoa/Cocoa.h>

@interface AJRPieChart : NSView 
{
    NSInteger _currentColor;
    NSColor *_backgroundColor;
    NSString *_backgroundLabel;
    NSMutableArray *_keys;
    NSMutableDictionary *_values;
    NSMutableDictionary *_displayValues;
    NSMutableDictionary *_colors;
    double _totalValue;
    NSFormatter *_valueFormatter;
    NSFont *_font;
    NSMutableDictionary *_attributes;
    NSMutableDictionary *_boldAttributes;
    
    BOOL _showKey;
    BOOL _showValues;
}

@property (nonatomic,strong) NSColor *backgroundColor;
@property (nonatomic,strong) NSString *backgroundLabel;
@property (nonatomic,assign) double totalValue;
@property (nonatomic,strong) NSFormatter *valueFormatter;
@property (nonatomic,strong) NSFont *font;
@property (nonatomic,assign) BOOL showKey;
@property (nonatomic,assign) BOOL showValues;

- (void)addValue:(CGFloat)value forKey:(NSString *)key;
- (void)addValue:(CGFloat)value forKey:(NSString *)key withColor:(NSColor *)color;
- (void)removeKey:(NSString *)key;

- (NSColor *)colorForKey:(NSString *)key;
- (void)setColor:(NSColor *)color forKey:(NSString *)key;
- (double)floatValueForKey:(NSString *)key;
- (void)setFloatValue:(double)value forKey:(NSString *)key;
- (double)displayValueForKey:(NSString *)key;
- (void)setDisplayValue:(double)value forKey:(NSString *)key;

@end
