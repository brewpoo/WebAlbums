// 
//  WAAlbum.m
//  WebAlbums
//
//  Created by JJL on 7/5/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

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
