// 
//  WAAlbum.m
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


#import "WAAlbum.h"

#import "WAPhoto.h"
#import "WAAccount.h"

@implementation WAAlbum 

@dynamic path;
@dynamic name;
@dynamic parent;
@dynamic photos;
@dynamic account;
@dynamic child;
@dynamic uniqueId;
@dynamic cachedCount;
@synthesize delegate;

- (NSInteger)depth {
	WAAlbum *current = self;
	NSInteger depth = 0;
	while (current.parent != nil) {
		depth++;
		current=current.parent;
	}
	return depth;
}

- (NSString*)fullName {
	WAAlbum *current = self;
	NSString *temp = self.name;
	while (current.parent != nil) {
		current = current.parent;
		temp = [NSString stringWithFormat:@"%@ - %@", current.name, temp];
	}
	return temp;
}
		


@end
