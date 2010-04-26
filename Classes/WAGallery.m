//
//  WAGallery.m
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


#import "WAGallery.h"
#import "WAAccount.h"
#import "ZWGallery.h"
#import "WAMultipleDownload.h"
#import "KCNetworkActivityIndicator.h"

@implementation WAGallery

@synthesize gallery;
@synthesize currentConnection;
@synthesize receivedData;
@synthesize downloads;
@synthesize currentAlbum;

- (id)init {
	self = [super init];
	self.name = @"Gallery2 Photo Gallery";
	self.identifier = @"gallery";
	self.image = @"gallery.png";
	return self;
}

+ (BOOL)validate:(WAAccount *)account {
	if (![account.accountType isEqualToString:@"gallery"] ||
		[account.name length] == 0 ||
		[account.url length] == 0) { return NO; }
	if ([account.requiresLogin boolValue] == YES && 
		([account.username length] == 0 || [account.formPassword length] == 0)) { return NO; }
	return YES;
}

#pragma mark 
#pragma mark WebAlbums Standard API 

// Need to make this asynchronous

- (void)establishConnection {
	
	[[KCNetworkActivityIndicator sharedIndicator] start];
	if ([account.requiresLogin boolValue] == TRUE) { 
		gallery = [ZWGallery galleryWithURL:[NSURL URLWithString:account.url] username:account.username];
		[gallery setPassword:[account fetchPassword]];
		[gallery login];
	} else {
		gallery = [ZWGallery galleryWithURL:[NSURL URLWithString:account.url]];
		[gallery nop];
	}
	[[KCNetworkActivityIndicator sharedIndicator] stop];
	[gallery retain];
	[self getAlbums];
}

- (void)getAlbums {
	currentConnection = [gallery getAlbumsWithDelegate:self];
	receivedData = [[[NSMutableData alloc] init] retain];
	[[KCNetworkActivityIndicator sharedIndicator] start];
}

-(void)getPhotosForAlbum:(WAAlbum*)album {
	currentAlbum = album.uniqueId;
	currentConnection = [gallery getItemsforAlbum:album.uniqueId withDelegate:self];
	receivedData = [[[NSMutableData alloc] init] retain];
	[[KCNetworkActivityIndicator sharedIndicator] start];

}


- (NSDictionary*)parseResponseData:(NSData*)responseData {
    NSString *response = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
    //NSLog(@"response = %@",response);
    if (response == nil) {
        NSLog(@"Could not convert response data into a string with encoding: %i", NSUTF8StringEncoding);
        return nil;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSScanner *scanner = [NSScanner scannerWithString:response];
    // first scan up to the #__GR2PROTO__ line
    [scanner scanUpToString:@"#__GR2PROTO__\n" intoString:nil];
    if (![scanner scanString:@"#__GR2PROTO__\n" intoString:nil]) {
        return nil;
    }
    while ([scanner isAtEnd] == NO) {
        NSString *line;
        if ([scanner scanUpToString:@"\n" intoString:&line]) {
            NSArray *pair = [line componentsSeparatedByString:@"="];
            if ([pair count] > 1) 
                [dict setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]];
        }
    }
    
    // "status" is required - let's help ourselves out and make it an int right now
    NSString *statusStr = [dict objectForKey:@"status"];
    if (statusStr == nil) {
        return nil;
    }
    [dict setObject:[NSNumber numberWithInt:[statusStr intValue]] forKey:@"statusCode"];
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

#pragma mark NSURLCOnnecton handlers
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {	
    [receivedData setLength:0];	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[[KCNetworkActivityIndicator sharedIndicator] stop];
    // release the connection, and the data object
    currentConnection=nil;
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	// inform the user
	NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[[KCNetworkActivityIndicator sharedIndicator] stop];
    // do something with the data
    // receivedData is declared as a method instance elsewher
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
	NSDictionary *response = [self parseResponseData:receivedData];
	NSLog(@"Data: %@",response);
    // release the connection, and the data object
    [currentConnection release];
    [receivedData release];	
	NSLog(@"status:%@",[response valueForKey:@"status_text"]);
	if ([[response valueForKey:@"status_text"] isEqual:@"Fetch-albums successful."]) {
		NSLog(@"Processing fetch-albums result");
		[account addGalleryAlbums:response];
	} else if ([[response valueForKey:@"status_text"] isEqual:@"Fetch-album-images successful."]) {
		NSLog(@"Processing fetch-album-images result");
		[account addGalleryPhotos:response toAlbum:[currentAlbum intValue]];		
		//NSArray *requests = [gallery requestsForPhotos:response];
		//downloads = [[WAMultipleDownload alloc] initWithRequests:requests];
		//downloads.delegate = self;
	}
}

- (void)dealloc {
	[gallery release];
	[currentConnection release];
	[receivedData release];
	[currentAlbum release];
	[super dealloc];
}

@end
