//
//  WAAlbum.h
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

