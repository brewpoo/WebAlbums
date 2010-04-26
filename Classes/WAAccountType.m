//
//  WAAccountType.m
//  WebAlbums
//
//  Created by JJL on 6/20/09.
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


#import "WAAccountType.h"

#import "WAFacebook.h"
#import "WAGenericUrl.h"
#import "WAGallery.h"
#import "WAPicasa.h"
#import "WAAccount.h"

@implementation WAAccountType

@synthesize name;
@synthesize image;
@synthesize identifier;
@synthesize account;

static NSArray *accountTypes;

+ (void)initialize {
	if (accountTypes==nil) {
		WAAccountType *picasaAccountType = [[WAPicasa alloc] init];
		WAAccountType *facebookAccountType = [[WAFacebook alloc ] init];
		WAAccountType *galleryAccountType = [[WAGallery alloc] init];
		WAAccountType *genericAccountType = [[WAGenericUrl alloc] init];
		accountTypes = [[ NSArray alloc ] initWithObjects:picasaAccountType, facebookAccountType, galleryAccountType, genericAccountType, nil];
		[picasaAccountType release];
		[facebookAccountType release];
		[galleryAccountType release];
		[genericAccountType release];
	}
}

+ (NSArray *)listAccountTypes {
//	[WAAccountType initialize];
	return accountTypes;
}

+ (BOOL)validate:(WAAccount *)account {
	return true;
}

- (id)initWithAccount:(WAAccount*)inAccount {
	self.account = [inAccount retain];
	return self;
}

- (void)establishConnection {
	// Place holder for children
}

- (void)getPhotosForAlbum:(WAAlbum*)album {
	// Override me
}

- (void)dealloc {
	[name release];
	[identifier release];
	[image release];
	[account release];
	[super dealloc];
}

@end
