//
//  WAFavoritePhoto.h
//  WebAlbums
//
//  Created by JJL on 7/5/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <CoreData/CoreData.h>

@class WAPhoto;

@interface WAFavoritePhoto :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) WAPhoto * photo;

@end


