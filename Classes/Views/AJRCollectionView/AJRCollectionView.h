/*!
 @header AJRCollectionView.h

 @author A.J. Raftis
 @updated 2/11/09.
 @copyright 2009 A.J. Raftis. All rights reserved.

 @abstract Put a one line description here.
 @discussion Put a brief discussion here.
 */

#import <Cocoa/Cocoa.h>

/*!
 @class AJRCollectionView
 @abstract A brief about the class
 @discussion A long talk about the class.
 */
@interface AJRCollectionView : NSCollectionView 
{
    NSString        *_searchString;
    NSTimeInterval    __lastSearchTime;
#if !defined(MAC_OS_X_VERSION_10_5) || MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5
    id                _delegate;
#endif
}

@property (nonatomic,strong) NSString *searchString;
#if !defined(MAC_OS_X_VERSION_10_5) || MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5
@property (nonatomic,retain) id delegate;
#endif

@end


@interface NSObject    (AJRCollectionView)

- (NSIndexSet *)collectionView:(NSCollectionView *)collectionView indexesForSearchString:(NSString *)searchString;

@end
