// 
//  WAPhoto.m
//  WebAlbums
//
//  Created by JJL on 7/5/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

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
