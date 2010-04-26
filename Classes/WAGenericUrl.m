//
//  WAGenericUrl.m
//  WebAlbums
//
//  Created by JJL on 6/20/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import "WAGenericUrl.h"
#import "WAAccount.h"

@implementation WAGenericUrl

- (id)init {
	self = [super init];
	self.name = @"Other...";
	self.identifier = @"generic";
	self.image = nil;
	return self;
}

+ (BOOL)validate:(WAAccount *)account {
	if (![account.accountType isEqualToString:@"generic"] ||
		[account.name length] == 0 ||
		[account.url length] == 0) { return NO; }
	return YES;
}

@end
