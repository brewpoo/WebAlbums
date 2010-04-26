//
//  WAFavoriteAlbum.h
//  WebAlbums
//
//  Created by JJL on 6/20/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <CoreData/CoreData.h>

@class WAAlbum;

@interface WAFavoriteAlbum :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) WAAlbum * album;

@end



