//
//  WAAddGenericViewController.m
//  WebAlbums
//
//  Created by JJL on 6/22/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import "WAAddGenericViewController.h"
#import "WATableFormControl.h"
#import "WATableFormSection.h"


@implementation WAAddGenericViewController

- (void)loadView {
	[super loadView];
	self.navigationItem.title = @"Generic";
	
	WATableFormSection *section = [[WATableFormSection alloc] init];
	[section.elements addObject:accountUrlElement];
	section.sectionHeader = @"Web page settings";
	[sections addObject:section];
	[section release];
	
}

- (void)dealloc {
    [super dealloc];
}


@end
