//
//  WAAddGalleryViewController.m
//  WebAlbums
//
//  Created by JJL on 6/22/09.
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
