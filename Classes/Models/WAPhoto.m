// 
//  WAPhoto.m
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


#import "WAPhoto.h"
#import "WAAlbum.h"

@implementation WAPhoto 

@dynamic wasViewed;
@dynamic title;
@dynamic caption;
@dynamic isCached;
@dynamic cachedImage;
@dynamic album;
@dynamic thumbnailPath;
@dynamic imagePath;
@dynamic uniqueId;
@dynamic someDate;

- (NSString*) dateTaken {	
	if (self.someDate == 0) {
		return @"";
	}
	 
	 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	 [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	 [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	 return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.someDate longLongValue]]];
}

@end
