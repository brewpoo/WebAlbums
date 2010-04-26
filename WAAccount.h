//
//  WAAccount.h
//  WebAlbums
//
//  Created by JJL on 7/5/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "GDataPhotos.h"

@class WAAlbum;

@protocol WAAccountDelegate <NSObject>
@optional
- (void)accountAlbumsUpdated;
- (void)albumPhotosUpdated;
@end

@interface WAAccount :  NSManagedObject  {
	NSString *password;
	NSString *formPassword;
	NSNumber *isNew;
	id<WAAccountDelegate> delegate;
}

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * accountType;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * isReadOnly;
@property (nonatomic, retain) NSNumber * requiresLogin;
@property (nonatomic, retain) NSNumber * isEnabled;
@property (nonatomic, retain) NSSet* albums;
@property (nonatomic, retain) NSMutableDictionary * settings;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *formPassword;
@property (nonatomic, retain) NSNumber *isNew;
@property (assign) id<WAAccountDelegate> delegate;

- (NSString *)serviceName;
- (NSString *)fetchPassword;
- (void)savePassword:(NSString *)value;

// Facebook integration
-(void)addFacebookAlbums:(NSArray*)newAlbums;
-(void)addFacebookPhotos:(NSArray*)newPhotos;

// Picasa Integration
-(void)addPicasaAlbums:(GDataFeedPhotoUser*)feed;
-(void)addPicasaPhotos:(GDataFeedPhotoAlbum*)feed;

// Gallery Integraton
-(void)addGalleryAlbums:(NSDictionary*)newAlbums;
-(void)addGalleryPhotos:(NSDictionary*)newPhotos toAlbum:(NSInteger)toAlbum;

@end

@interface WAAccount (CoreDataGeneratedAccessors)
- (void)addAlbumsObject:(WAAlbum *)value;
- (void)removeAlbumsObject:(WAAlbum *)value;
- (void)addAlbums:(NSSet *)value;
- (void)removeAlbums:(NSSet *)value;

@end



