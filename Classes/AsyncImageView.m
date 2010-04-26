//
//  AsyncImageView.m
//  WebAlbums
//
//  Created by JJL on 7/22/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import "AsyncImageView.h"
#import "ImageCache.h"
#import "KCNetworkActivityIndicator.h"

// This class demonstrates how the URL loading system can be used to make a UIView subclass
// that can download and display an image asynchronously so that the app doesn't block or freeze
// while the image is downloading. It works fine in a UITableView or other cases where there
// are multiple images being downloaded and displayed all at the same time. 

@implementation AsyncImageView

- (void)dealloc {
	[connection cancel]; //in case the URL is still downloading
	[connection release];
	[thisUrl release];
	[data release];
	[super dealloc];
}

/*
- (void)loadImageFromURL:(NSURL*)url {
	if (connection!=nil) { [connection release]; } //in case we are downloading a 2nd image
	if (data!=nil) { [data release]; }
	
	NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; //notice how delegate set to self object
	//TODO error handling, what if connection is nil?
}
 */

- (void)loadImageFromURL:(NSURL*)url {
	if (connection!=nil)
	{
		[connection cancel];
		[connection release];
		connection = nil;
	}
	if (data!=nil)
	{
		[data release];
		data = nil;
	}
	thisUrl = [url retain];
	
	// First check cache
	if ([[ImageCache sharedImageCache] hasImageWithKey:[url absoluteString]]) {
		//make an image view for the image
		UIImage *img = [[ImageCache sharedImageCache] imageForKey:[url absoluteString]];
		self.image = img;
		self.frame = self.bounds;
		[self setNeedsLayout];
		return;
	}
	
	// Turn on Activity Indicators
	[[KCNetworkActivityIndicator sharedIndicator] start];
	activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	activity.hidesWhenStopped = YES;
	activity.center = CGPointMake(60.0,60.0); // Image size/2
	[activity startAnimating];
	[self addSubview:activity];
	
	NSURLRequest* request = [NSURLRequest requestWithURL:url
											 cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
	
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

//the URL connection calls this repeatedly as data arrives
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
	if (data==nil) { data = [[NSMutableData alloc] initWithCapacity:2048]; }
	[data appendData:incrementalData];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	return nil;
}

//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	//so self data now has the complete image
	[connection release];
	connection=nil;
	
	// Cache the image
	//make an image view for the image
	UIImage *img = [UIImage imageWithData:data];
	self.image = img;
	self.frame = self.bounds;
	[[ImageCache sharedImageCache] storeImage:img withKey:[thisUrl absoluteString]]; 

	[self setNeedsLayout];
	// Turn off activity indicators
	[activity stopAnimating];
	[activity removeFromSuperview];
	[activity release];
	
	[data release]; //don’t need this any more, its in the UIImageView now
	data=nil;
	[[KCNetworkActivityIndicator sharedIndicator] stop];
}

@end

