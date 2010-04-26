//
//  WAPhoto.h
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



