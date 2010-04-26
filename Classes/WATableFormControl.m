//
//  WATableFormControl.m
//  WebAlbums
//
//  Created by JJL on 6/24/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import "WATableFormControl.h"


@implementation WATableFormControl

@synthesize control;
@synthesize label;

-(void)addControl:(NSObject *)newControl {
	if (control != newControl) {
		[control release];
		control = [newControl retain];
	}
}

@end
