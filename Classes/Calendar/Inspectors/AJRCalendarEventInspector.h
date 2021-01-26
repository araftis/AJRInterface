//
//  AJRCalendarEventInspector.h
//  AJRInterface
//
//  Created by A.J. Raftis on 6/5/09.
//  Copyright 2009 A.J. Raftis. All rights reserved.
//

#import <AJRInterface/AJRCalendarItemInspector.h>

@interface AJRCalendarEventInspector : AJRCalendarItemInspector
{
    NSDateFormatter        *_dateFormatter;
    NSMutableDictionary    *_valueAttributes;
    id                    _initialFirstResponder;
}

@end
