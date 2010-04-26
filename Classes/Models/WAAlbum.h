//
//  WAAlbum.h
//  WebAlbums
//
//  Created by JJL on 7/5/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <CoreData/CoreData.h>

@class WAPhoto;
@class WAAccount;

@protocol WAAlbumDelegate <NSObject>
- (void)albumPhotosUpdated;
@end

@interface WAAlbum :  NSManagedObject  {
	id<WAAlbumDelegate> delegate;
}

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) WAAlbum * parent;
@property (nonatomic, retain) NSSet* photos;
@property (nonatomic, retain) WAAccount * account;
@property (nonatomic, retain) NSSet* child;
@property (nonatomic, retain) NSNumber * uniqueId;
@property (nonatomic, retain) NSNumber * cachedCount;

@property (assign) id<WAAlbumDelegate> delegate;

- (NSInteger)depth;

@end


@interface WAAlbum (CoreDataGeneratedAccessors)
- (void)addPhotosObject:(WAPhoto *)value;
- (void)removePhotosObject:(WAPhoto *)value;
- (void)addPhotos:(NSSet *)value;
- (void)removePhotos:(NSSet *)value;

- (void)addChildObject:(WAAlbum *)value;
- (void)removeChildObject:(WAAlbum *)value;
- (void)addChild:(NSSet *)value;
- (void)removeChild:(NSSet *)value;

@end

