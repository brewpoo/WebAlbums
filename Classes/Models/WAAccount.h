//
//  WAAccount.h
//  WebAlbums
//
//  Created by JJL on 7/5/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

/*
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */


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



