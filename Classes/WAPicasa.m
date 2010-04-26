//
//  WAPicasa.m
//  WebAlbums
//
//  Created by JJL on 6/22/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import "WAPicasa.h"
#import "WAAccount.h"
#import "GDataPhotos.h"
#import "KCNetworkActivityIndicator.h"

@implementation WAPicasa

@synthesize service;

- (id)init {
	self = [super init];
	self.name = @"Picasa";
	self.identifier = @"picasa";
	self.image = @"picasa.png";
	return self;
}

+ (BOOL)validate:(WAAccount *)account {
	if (![account.accountType isEqualToString:@"picasa"] ||
		[account.name length] == 0 ||
		[account.username length] == 0 ||
		[account.formPassword length] == 0 ) { return NO; }
	return YES ;
}
	
# pragma mark WebAlbums required

- (void)establishConnection {
	service = [[self googlePhotosService] retain];
	if (service) {
		[self getAlbums];
	}
}

- (void)getAlbums {
	NSLog(@"Picasa: executing get albums");
	GDataServiceTicket *ticket;
	
	NSURL *feedURL = [GDataServiceGooglePhotos photoFeedURLForUserID:account.username
															 albumID:nil
														   albumName:nil
															 photoID:nil
																kind:nil
															  access:nil];
	ticket = [service fetchPhotoFeedWithURL:feedURL
								   delegate:self
						  didFinishSelector:@selector(albumListFetchTicket:finishedWithFeed:)
							didFailSelector:@selector(albumListFetchTicket:failedWithError:)];
	[[KCNetworkActivityIndicator sharedIndicator] start];

}

- (void)getPhotosForAlbum:(WAAlbum*)album {
	NSLog(@"Picasa: executing get photos");
	GDataServiceTicket *ticket;
	
	if (album) {
		
		// fetch the photos feed
		NSURL *feedURL = [NSURL URLWithString:[album path]];
		if (feedURL) {
			ticket = [service fetchPhotoFeedWithURL:feedURL
										   delegate:self
								  didFinishSelector:@selector(photosTicket:finishedWithFeed:)
									didFailSelector:@selector(photosTicket:failedWithError:)];
			[[KCNetworkActivityIndicator sharedIndicator] start];
		}
	}
}
	

#pragma mark Google Integeration

- (GDataServiceGooglePhotos *)googlePhotosService {
	if (!service) {
		service = [[GDataServiceGooglePhotos alloc] init];
			
		[service setUserAgent:@"NetguyzApps-WebAlbums-1.0"]; // set this to yourName-appName-appVersion
		[service setShouldCacheDatedData:YES];
		[service setServiceShouldFollowNextLinks:YES];
	}
		
	if ([account.username length]) {
		[service setUserCredentialsWithUsername:account.username password:[account fetchPassword]];
	} else {
		[service setUserCredentialsWithUsername:nil password:nil];
	}
	return service;
}

// finished album list successfully
- (void)albumListFetchTicket:(GDataServiceTicket *)ticket
            finishedWithFeed:(GDataFeedPhotoUser *)feed {
	
#ifdef DEBUG
	NSLog(@"Got Album List Results: %@", [feed entries]);
#endif

	[[KCNetworkActivityIndicator sharedIndicator] stop];
	[account addPicasaAlbums:feed];
} 

// failed
- (void)albumListFetchTicket:(GDataServiceTicket *)ticket
			 failedWithError:(NSError *)error {
	
	[[KCNetworkActivityIndicator sharedIndicator] stop];
#ifdef DEBUG
	NSLog(@"Received Error for Album List Results");
#endif
}


// fetched photo list successfully
- (void)photosTicket:(GDataServiceTicket *)ticket
    finishedWithFeed:(GDataFeedPhotoAlbum *)feed {
#ifdef DEBUG
	NSLog(@"Got Photo list Results: %@", [feed entries]);
#endif
	[[KCNetworkActivityIndicator sharedIndicator] stop];
	[account addPicasaPhotos:feed];
} 

// failed
- (void)photosTicket:(GDataServiceTicket *)ticket
	 failedWithError:(NSError *)error {
#ifdef DEBUG
	NSLog(@"Received Error for Photo List Result");
#endif
	[[KCNetworkActivityIndicator sharedIndicator] stop];

}


- (void) dealloc {
	[service release];
	[super dealloc];
}

@end
