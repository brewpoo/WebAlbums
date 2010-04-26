//
//  WATableFormSection.m
//  WebAlbums
//
//  Created by JJL on 6/24/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import "WATableFormSection.h"


@implementation WATableFormSection

@synthesize elements;
@synthesize sectionHeader;
@synthesize isVisible;

-(id)init {
	if (self = [super init]) {
		self.elements = [[[NSMutableArray alloc] init] retain];
	}
	return self;
}

-(void)dealloc {
	[elements release];
	[super dealloc];
}

@end
