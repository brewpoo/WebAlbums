//
//  WAAddPicassViewController.m
//  WebAlbums
//
//  Created by JJL on 6/22/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import "WAAddPicasaViewController.h"
#import "WATableFormControl.h"
#import "WATableFormSection.h"


@implementation WAAddPicasaViewController

- (void)loadView {
	[super loadView];
	self.navigationItem.title = @"Picasa Albums";
		
	WATableFormSection *section = [[WATableFormSection alloc] init];
	section.sectionHeader = @"Google account details";
	[section.elements addObject:emailElement];
	[section.elements addObject:passWordElement];
	[sections addObject:section];
	[section release];
	
}

- (void)dealloc {
    [super dealloc];
}


@end
