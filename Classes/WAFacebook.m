//
//  WAFacebook.m
//  WebAlbums
//
//  Created by JJL on 6/20/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import "WAFacebook.h"
#import "WAAccount.h"
#import "WebAlbumsAppDelegate.h"
#import "FBConnect/FBConnect.h"

#import "Constants.h"
#import "KCNetworkActivityIndicator.h"

@implementation WAFacebook

@synthesize session;

- (id)init {
	self = [super init];
	self.name = @"Facebook";
	self.identifier = @"facebook";
	self.image = @"facebook.png";
	return self;
}

+ (BOOL)validate:(WAAccount *)account {
	if (![account.accountType isEqualToString:@"facebook"] ||
		[account.name length] == 0 ) { return NO; }
	return YES ;
}

#pragma mark 
#pragma mark WebAlbums Standard API 

- (void)establishConnection {
	session = [FBSession sessionForApplication:FACEBOOK_API_KEY secret:FACEBOOK_APP_SECRET delegate:self];
	if ([session resume]==NO) {
		FBLoginDialog* dialog = [[[FBLoginDialog alloc] initWithSession:session] autorelease];
		[dialog show];
	}
	[session retain];
}

- (void)getAlbums {
	NSDictionary *params = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%qu", session.uid] forKey:@"uid"];
#ifdef DEBUG
	NSLog(@"User ID: %lld", session.uid);
	NSLog(@"Params: %@", params);
#endif
	[[FBRequest requestWithDelegate:self] call:@"facebook.Photos.getAlbums" params:params];
	[[KCNetworkActivityIndicator sharedIndicator] start];
	
}

- (void)getPhotosForAlbum:(WAAlbum*)album {
	// Need to differntiate between normal albums and tagged photos
	NSDictionary *params;
	if ([album.uniqueId intValue] == 1) {
		// tagged PHotos
		params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"qu", session.uid], @"uid",
				  [NSString stringWithFormat:@"%qu", session.uid], @"subj_id", nil];
	} else {
		params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%qu", session.uid], @"uid",
				  [NSString stringWithFormat:@"%qu", [album.uniqueId longLongValue]], @"aid", nil];
	}
#ifdef DEBUG
	NSLog(@"Requesting photos for album: %@", album);
	NSLog(@"Params: %@", params);
#endif
	[[FBRequest requestWithDelegate:self] call:@"facebook.Photos.get" params:params];
	[[KCNetworkActivityIndicator sharedIndicator] start];
}


#pragma mark
#pragma mark Facebook Specific
	
// Facebook Delegate Method
- (void)session:(FBSession*)session didLogin:(FBUID)uid {
	NSLog(@"User with id %lld logged in.", uid);
	[self getAlbums];
}

- (void)request:(FBRequest*)request didLoad:(id)result {
	// Process request results, need to call accountType specific
	// method to handle unique data mappings
	[[KCNetworkActivityIndicator sharedIndicator] stop];
	NSLog(@"Got result: %@", request);
	if ([request.method isEqualToString:@"facebook.Photos.getAlbums"]) {
#ifdef DEBUG
		NSLog(@"Facebook API: received Photos.getAlbums response");
#endif
		[account addFacebookAlbums:result];
		// view controller is notified via delegate relationship
		// of update album list
		return;
	}
	if ([request.method isEqualToString:@"facebook.Photos.get"]) {
#ifdef DEBUG
		NSLog(@"Facebook API: received Photos.get response");
#endif
		[account addFacebookPhotos:result];
		// View controller is notified via delegate relationship
		// of update photos
		return;
	}
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
#ifdef DEBUG
	NSLog(@"Facebook returned error: %@", error);
#endif
}


- (void)dialogDidCancel:(FBDialog*)dialog {
//	[((WebAlbumsAppDelegate *)[UIApplication sharedApplication].delegate).tabBarController.selectedViewController popNavigationItemAnimated:YES];
	// Somehow pop the navigaton controller
}

- (void)dealloc {
	[session release];
	[super dealloc];
}

@end
