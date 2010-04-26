//
//  WAPhoto.h
//  WebAlbums
//
//  Created by JJL on 7/5/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <CoreData/CoreData.h>

@class WAAlbum;

@interface WAPhoto :  NSManagedObject  {
}

@property (nonatomic, retain) NSNumber * wasViewed;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSNumber * isCached;
@property (nonatomic, retain) NSData * cachedImage;
@property (nonatomic, retain) WAAlbum * album;
@property (nonatomic, retain) NSString * thumbnailPath;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSNumber * uniqueId;
@property (nonatomic, retain) NSNumber * someDate;

- (NSString*) dateTaken;

@end



