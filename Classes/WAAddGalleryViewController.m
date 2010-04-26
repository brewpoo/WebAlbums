//
//  WAAddGalleryViewController.m
//  WebAlbums
//
//  Created by JJL on 6/22/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import "WAAccountFormViewController.h"
#import "WAAddGalleryViewController.h"
#import "WATableFormControl.h"
#import "WATableFormSection.h"

@implementation WAAddGalleryViewController

- (void)loadView {
	[super loadView];
	self.navigationItem.title = @"Gallery";
	
	WATableFormSection *section = [[WATableFormSection alloc] init];
	[section.elements addObject:accountUrlElement];
	section.sectionHeader = @"Gallery connections details";
	[sections addObject:section];
	[section release];
	
	WATableFormSection *section1 = [[WATableFormSection alloc] init];
	[section1.elements addObject:loginRequiredElement];
	[sections addObject:section1];
	[section1 release];
	
	WATableFormSection *section2 = [[WATableFormSection alloc] init];
	[section2.elements addObject:userNameElement];
	[section2.elements addObject:passWordElement];
	[sections addObject:section2];
	[section2 release];
	
	account.accountType = @"gallery";

}
	

- (void)dealloc {
    [super dealloc];
}


@end
