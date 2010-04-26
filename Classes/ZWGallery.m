//
// Copyright (c) Zach Wily
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, 
// are permitted provided that the following conditions are met:
// 
// - Redistributions of source code must retain the above copyright notice, this 
//     list of conditions and the following disclaimer.
// 
// - Redistributions in binary form must reproduce the above copyright notice, this
//     list of conditions and the following disclaimer in the documentation and/or 
//     other materials provided with the distribution.
// 
// - Neither the name of Zach Wily nor the names of its contributors may be used to 
//     endorse or promote products derived from this software without specific prior 
//     written permission.
// 
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR 
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON 
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "ZWGallery.h"
#import "ZWGalleryAlbum.h"
#import "NSString+misc.h"
#import "ZWURLConnection.h"
//#import "InterThreadMessaging.h"
#import "ZWMutableURLRequest.h"

@interface ZWGallery (PrivateAPI)
- (void)loginThread:(NSDictionary *)threadDispatchInfo;
- (ZWGalleryRemoteStatusCode)doLogin;

- (void)getAlbumsThread:(NSDictionary *)threadDispatchInfo;
- (ZWGalleryRemoteStatusCode)doGetAlbums;

- (void)createAlbumThread:(NSDictionary *)threadDispatchInfo;
- (ZWGalleryRemoteStatusCode)doCreateAlbumWithName:(NSString *)name title:(NSString *)title summary:(NSString *)summary parent:(ZWGalleryAlbum *)parent;

@end

@implementation ZWGallery

#pragma mark Object Life Cycle

- (id)init {
    return self;
}

- (id)initWithURL:(NSURL*)newUrl {
	url = [newUrl retain];
	username = nil;
	delegate = self;
	loggedIn = TRUE;
	majorVersion = 0;
	minorVersion = 0;
	type = GalleryTypeG2;
	return self;
}

- (id)initWithURL:(NSURL*)newUrl username:(NSString*)newUsername {
    url = [newUrl retain];
    fullURL = [[NSURL alloc] initWithString:[[url absoluteString] stringByAppendingString:@"gallery_remote2.php"]];
    username = [newUsername retain];
    delegate = self;
    loggedIn = FALSE;
    majorVersion = 0;
    minorVersion = 0;
    type = GalleryTypeG2;
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary {
    [self initWithURL:[NSURL URLWithString:[dictionary objectForKey:@"url"]] 
             username:[dictionary objectForKey:@"username"]];
    
    NSNumber *typeNumber = [dictionary objectForKey:@"type"];
    if (typeNumber)
        type = [typeNumber intValue];
    
    return self;
}

+ (ZWGallery*)galleryWithURL:(NSURL*)newUrl {
    return [[[ZWGallery alloc] initWithURL:newUrl] autorelease];
}

+ (ZWGallery*)galleryWithURL:(NSURL*)newUrl username:(NSString*)newUsername {
    return [[[ZWGallery alloc] initWithURL:newUrl username:newUsername] autorelease];
}

+ (ZWGallery*)galleryWithDictionary:(NSDictionary*)dictionary {
    return [[[ZWGallery alloc] initWithDictionary:dictionary] autorelease];
}

- (void)dealloc
{
    [url release];
    [username release];
    [password release];
    [albums release];
    [lastCreatedAlbumName release];
    
    [super dealloc];
}

#pragma mark NSComparisonMethods

- (BOOL)isEqual:(id)gal
{
    return ([username isEqual:[gal username]] && [[url absoluteString] isEqual:[[gal url] absoluteString]]);
}

- (NSComparisonResult)compare:(id)gal
{
    return [[self identifier] caseInsensitiveCompare:[gal identifier]];
}

#pragma mark Accessors

- (void)setDelegate:(id)newDelegate {
    delegate = newDelegate;
}

- (id)delegate {
    return delegate;
}

- (void)setPassword:(NSString*)newPassword {
    [newPassword retain];
    [password release];
    password = newPassword;
}

- (NSURL*)url {
    return url;
}

- (NSURL*)fullURL {
    return fullURL;
}

- (NSString*)identifier {
    return [NSString stringWithFormat:@"%@%@ (%@)", [url host], [url path], username];
}

- (NSString*)urlString {
    return [url absoluteString];
}

- (NSString*)username {
    return username;
}

- (int)majorVersion {
    return majorVersion;
}

- (int)minorVersion {
    return minorVersion;
}

- (BOOL)loggedIn {
    return loggedIn;
}

- (NSArray*)albums {
    return albums;
}

- (NSDictionary*)infoDictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:
        username, @"username",
        [url absoluteString], @"url",
        [NSNumber numberWithInt:(int)type], @"type",
        nil];
}

- (BOOL)isGalleryV2 {
	return ([self type] == GalleryTypeG2 || [self type] == GalleryTypeG2XMLRPC);
}

- (ZWGalleryType)type {
    return type;
}

- (NSString *)lastCreatedAlbumName
{
    return lastCreatedAlbumName;
}

- (NSStringEncoding)sniffedEncoding
{
    return sniffedEncoding;
}

#pragma mark Actions

- (void)cancelOperation {
    [currentConnection cancel];
}


- (void)logout {
    loggedIn = FALSE;
}

#pragma mark NSURLCOnnecton handlers
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {	
    [receivedData setLength:0];	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
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
    // do something with the data
    // receivedData is declared as a method instance elsewher
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
	NSDictionary *response = [self parseResponseData:receivedData];
	NSLog(@"Data: %@",response);
    // release the connection, and the data object
    [connection release];
    [receivedData release];	
	NSLog(@"status:%@",[response valueForKey:@"status_text"]);
	if ([[response valueForKey:@"status_text"] isEqual:@"Fetch-albums successful."]) {
		NSLog(@"Processing fetch-albums result");
		[self processAlbums:response];
	}
}


#pragma mark Helpers

- (NSDictionary*)parseResponseData:(NSData*)responseData {
    NSString *response = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"response = %@",response);
    if (response == nil) {
        NSLog(@"Could not convert response data into a string with encoding: %i", [self sniffedEncoding]);
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

- (NSString *)formNameWithName:(NSString *)paramName {
    // Gallery 1 names don't need mangling
    if (![self isGalleryV2]) 
        return paramName;
    
    // For some reason userfile is just changed to g2_userfile
    if ([paramName isEqualToString:@"userfile"])
        return @"g2_userfile";
    
    // All other G2 params are mangled like this:
    return [NSString stringWithFormat:@"g2_form[%@]", paramName];
}

#pragma mark Threads

    
- (ZWGalleryRemoteStatusCode)login {
    // remove the cookies sent to the gallery (the login function ain't so smart)
    NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStore cookiesForURL:fullURL];
    id cookie;
    NSEnumerator *enumerator = [cookies objectEnumerator];
    while (cookie = [enumerator nextObject]) {
        [cookieStore deleteCookie:cookie];
    }
    
    // do an initial connection to get the session key
    NSMutableURLRequest *setupRequest = [NSMutableURLRequest requestWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:60.0];
    [setupRequest setHTTPMethod:@"GET"];
   
	NSLog(@"Sending request");
    currentConnection = [ZWURLConnection connectionWithRequest:setupRequest];
    while ([currentConnection isRunning]) 
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    
	NSLog(@"Got response");
    if ([currentConnection isCancelled]) {
		NSLog(@"Did Cancel");
        return ZW_GALLERY_OPERATION_DID_CANCEL;
	}
    
	NSLog(@"Setting encoding");
    // Default to UTF-8
    sniffedEncoding = NSUTF8StringEncoding;
    NSURLResponse *response = [currentConnection response];
    NSString *encodingString = [response textEncodingName];
    if (encodingString) {
        CFStringEncoding cfStrEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)encodingString);
        if (cfStrEncoding)
            sniffedEncoding = CFStringConvertEncodingToNSStringEncoding(cfStrEncoding);
    }
    if (!sniffedEncoding)
        sniffedEncoding = NSUTF8StringEncoding;
    NSLog(@"Now logging in");
    // Now try to log in (try twice - switch to other type of gallery if first try fails)
    BOOL tryGalleryV2 = NO;
    NSDictionary *galleryResponse = nil;
    int tries;
    for (tries = 0; tries < 4; tries++) {
        if (!tryGalleryV2) {
			NSLog(@"Trying Gallery v1");
            // try logging into Gallery v1
            fullURL = [[NSURL alloc] initWithString:[[url absoluteString] stringByAppendingString:@"gallery_remote2.php"]];
            NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:fullURL
                                                                      cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                  timeoutInterval:60.0];
            [theRequest setValue:@"WebAlbums" forHTTPHeaderField:@"User-Agent"];
            
            [theRequest setHTTPMethod:@"POST"];
            
            NSString *requestString = [NSString stringWithFormat:@"cmd=login&protocol_version=2.1&uname=%s&password=%s",
                [[username stringByEscapingURL] UTF8String], [[password stringByEscapingURL] UTF8String]];
            NSData *requestData = [requestString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            [theRequest setHTTPBody:requestData];
            
            currentConnection = [ZWURLConnection connectionWithRequest:theRequest];
            while ([currentConnection isRunning]) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
            }
            
            if ([currentConnection isCancelled]) 
                return ZW_GALLERY_OPERATION_DID_CANCEL;
            
            NSData *data = [currentConnection data];
            response = [currentConnection response];

            if (data == nil) {
                if (tryGalleryV2) 
                    return ZW_GALLERY_COULD_NOT_CONNECT;
                
                // There is at least one instance (reported by adeh@desandies.com) where 
                // data will be nil, even though a G2 installation does exist. In that case,
                // let's try G2 if we haven't already.
                tryGalleryV2 = YES;
                continue;
            }
            
			NSLog(@"Got some data %@", data);
            galleryResponse = [self parseResponseData:data];
            
            if ([(NSHTTPURLResponse *)response statusCode] == 404 || galleryResponse == nil) 
                tryGalleryV2 = YES;
            else {
                // we successfully logged into a G1
                type = GalleryTypeG1;
                break;
            }
        }
        else {
			NSLog(@"Trying Gallery v2");
            // try logging into Gallery v2
            fullURL = [[NSURL alloc] initWithString:[[url absoluteString] stringByAppendingString:@"main.php"]];
            
            NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:fullURL
                                                                      cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                  timeoutInterval:60.0];
            [theRequest setValue:@"WebAlbums" forHTTPHeaderField:@"User-Agent"];
            [theRequest setHTTPMethod:@"POST"];
            
            NSString *requestString = [NSString stringWithFormat:@"g2_controller=remote:GalleryRemote&g2_form[cmd]=login&g2_form[protocol_version]=2.2&g2_form[uname]=%s&g2_form[password]=%s",
                [[username stringByEscapingURL] UTF8String], [[password stringByEscapingURL] UTF8String]];
            NSData *requestData = [requestString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            [theRequest setHTTPBody:requestData];
            
            currentConnection = [ZWURLConnection connectionWithRequest:theRequest];
            while ([currentConnection isRunning]) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
            }
            
            if ([currentConnection isCancelled]) 
                return ZW_GALLERY_OPERATION_DID_CANCEL;
            
            NSData *data = [currentConnection data];
            response = [currentConnection response];
            
            if (data == nil) 
                return ZW_GALLERY_COULD_NOT_CONNECT;
			NSLog(@"Got some data %@", data);

            galleryResponse = [self parseResponseData:data];
            if ([(NSHTTPURLResponse *)response statusCode] == 404 || galleryResponse == nil) 
                tryGalleryV2 = NO;
            else {
                // we successfully logged into a G2
                type = GalleryTypeG2;
                break;
            }
        }
    }
    
    if (galleryResponse == nil) 
        return ZW_GALLERY_PROTOCOL_ERROR;
    
    ZWGalleryRemoteStatusCode status = (ZWGalleryRemoteStatusCode)[[galleryResponse objectForKey:@"statusCode"] intValue];
    
    if (status == GR_STAT_PASSWD_WRONG) 
        return GR_STAT_PASSWD_WRONG;
    
    // lookup version
    NSString *version = [galleryResponse objectForKey:@"server_version"];
    if (version == nil) 
        return ZW_GALLERY_PROTOCOL_ERROR;
    NSArray *versionArray = [version componentsSeparatedByString:@"."];
    majorVersion = [[versionArray objectAtIndex:0] intValue];
    minorVersion = [[versionArray objectAtIndex:1] intValue];
    
    if (status == GR_STAT_SUCCESS) {
        loggedIn = YES;
        
        NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[(NSHTTPURLResponse*)response allHeaderFields] forURL:fullURL];
        NSEnumerator *c = [cookies objectEnumerator];
        id cookie;
        while (cookie = [c nextObject]) 
            [cookieStore setCookie:cookie];

        return GR_STAT_SUCCESS;
    }
    
    return ZW_GALLERY_UNKNOWN_ERROR;
}

- (ZWGalleryRemoteStatusCode)nop {
    
    // do an initial connection to get the session key
    NSMutableURLRequest *setupRequest = [NSMutableURLRequest requestWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:60.0];
    [setupRequest setHTTPMethod:@"GET"];
	currentConnection = [ZWURLConnection connectionWithRequest:setupRequest];
    while ([currentConnection isRunning]) 
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    
    if ([currentConnection isCancelled]) {
        return ZW_GALLERY_OPERATION_DID_CANCEL;
	}
    
    // Default to UTF-8
    sniffedEncoding = NSUTF8StringEncoding;
    NSURLResponse *response = [currentConnection response];
    NSString *encodingString = [response textEncodingName];
    if (encodingString) {
        CFStringEncoding cfStrEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)encodingString);
        if (cfStrEncoding)
            sniffedEncoding = CFStringConvertEncodingToNSStringEncoding(cfStrEncoding);
    }
    if (!sniffedEncoding)
        sniffedEncoding = NSUTF8StringEncoding;

    // Now try to log in (try twice - switch to other type of gallery if first try fails)
    BOOL tryGalleryV2 = NO;
    NSDictionary *galleryResponse = nil;
    int tries;
    for (tries = 0; tries < 4; tries++) {
        if (!tryGalleryV2) {
			NSLog(@"Trying Gallery v1");
            // try logging into Gallery v1
            fullURL = [[NSURL alloc] initWithString:[[url absoluteString] stringByAppendingString:@"gallery_remote2.php"]];
            NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:fullURL
                                                                      cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                  timeoutInterval:60.0];
            [theRequest setValue:@"WebAlbums" forHTTPHeaderField:@"User-Agent"];
            
            [theRequest setHTTPMethod:@"POST"];
            
            NSString *requestString = @"cmd=nop&protocol_version=2.1";
            NSData *requestData = [requestString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            [theRequest setHTTPBody:requestData];
            
            currentConnection = [ZWURLConnection connectionWithRequest:theRequest];
            while ([currentConnection isRunning]) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
            }
            
            if ([currentConnection isCancelled]) 
                return ZW_GALLERY_OPERATION_DID_CANCEL;
            
            NSData *data = [currentConnection data];
            response = [currentConnection response];
			
            if (data == nil) {
                if (tryGalleryV2) 
                    return ZW_GALLERY_COULD_NOT_CONNECT;
                
                // There is at least one instance (reported by adeh@desandies.com) where 
                // data will be nil, even though a G2 installation does exist. In that case,
                // let's try G2 if we haven't already.
                tryGalleryV2 = YES;
                continue;
            }
            
            galleryResponse = [self parseResponseData:data];
            
            if ([(NSHTTPURLResponse *)response statusCode] == 404 || galleryResponse == nil) 
                tryGalleryV2 = YES;
            else {
                // we successfully logged into a G1
                type = GalleryTypeG1;
                break;
            }
        }
        else {
            // try logging into Gallery v2
            fullURL = [[NSURL alloc] initWithString:[[url absoluteString] stringByAppendingString:@"main.php"]];
            
            NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:fullURL
                                                                      cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                  timeoutInterval:60.0];
            [theRequest setValue:@"WebAlbums" forHTTPHeaderField:@"User-Agent"];
            [theRequest setHTTPMethod:@"POST"];
            
            NSString *requestString = @"g2_controller=remote:GalleryRemote&g2_form[cmd]=nop&g2_form[protocol_version]=2.2";
            NSData *requestData = [requestString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            [theRequest setHTTPBody:requestData];
            
            currentConnection = [ZWURLConnection connectionWithRequest:theRequest];
            while ([currentConnection isRunning]) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
            }
            
            if ([currentConnection isCancelled]) 
                return ZW_GALLERY_OPERATION_DID_CANCEL;
            
            NSData *data = [currentConnection data];
            response = [currentConnection response];
            
            if (data == nil) 
                return ZW_GALLERY_COULD_NOT_CONNECT;
			
            galleryResponse = [self parseResponseData:data];
            if ([(NSHTTPURLResponse *)response statusCode] == 404 || galleryResponse == nil) 
                tryGalleryV2 = NO;
            else {
                // we successfully logged into a G2
                type = GalleryTypeG2;
                break;
            }
        }
    }
    
    if (galleryResponse == nil) 
        return ZW_GALLERY_PROTOCOL_ERROR;
    
    ZWGalleryRemoteStatusCode status = (ZWGalleryRemoteStatusCode)[[galleryResponse objectForKey:@"statusCode"] intValue];
    
    if (status == GR_STAT_PASSWD_WRONG) 
        return GR_STAT_PASSWD_WRONG;
    
    // lookup version
    NSString *version = [galleryResponse objectForKey:@"server_version"];
    if (version == nil) 
        return ZW_GALLERY_PROTOCOL_ERROR;
    NSArray *versionArray = [version componentsSeparatedByString:@"."];
    majorVersion = [[versionArray objectAtIndex:0] intValue];
    minorVersion = [[versionArray objectAtIndex:1] intValue];
    
    if (status == GR_STAT_SUCCESS) {
		NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        loggedIn = YES;
        
        NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[(NSHTTPURLResponse*)response allHeaderFields] forURL:fullURL];
        NSEnumerator *c = [cookies objectEnumerator];
        id cookie;
        while (cookie = [c nextObject]) 
            [cookieStore setCookie:cookie];
		
        return GR_STAT_SUCCESS;
    }
    
    return ZW_GALLERY_UNKNOWN_ERROR;
}


- (void)requestWithDelegate:(id)thisDelegate call:(NSString*)rpc params:(NSDictionary*)params {
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:fullURL
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:60.0];
    [theRequest setValue:@"WebAlbums" forHTTPHeaderField:@"User-Agent"];
	
    [theRequest setHTTPMethod:@"POST"];
    
    NSMutableString *requestString = [NSMutableString stringWithFormat:@"cmd=%d&protocol_version=2.1", rpc];

	if (type == GalleryTypeG2) 
		requestString = [NSString stringWithFormat:@"g2_controller=remote:GalleryRemote&g2_form[cmd]=%@&g2_form[protocol_version]=2.3", rpc];
	
	for (NSString* key in [params keyEnumerator]) {
		NSString* value = [params objectForKey:key];
		[requestString appendString:[NSString stringWithFormat:@"%@=%@", key, value]];
	}
	
	NSLog(@"Sending: %@", requestString);
	
    NSData *requestData = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    [theRequest setHTTPBody:requestData];
	/* 
	 currentConnection = [ZWURLConnection connectionWithRequest:theRequest];
	 while ([currentConnection isRunning]) 
	 [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
	 
	 if ([currentConnection isCancelled]) 
	 return ZW_GALLERY_OPERATION_DID_CANCEL;
	 
	 NSData *data = [currentConnection data];
	 
	 if (data == nil) 
	 return ZW_GALLERY_COULD_NOT_CONNECT;
	 NSLog(@"Got some data %@", data);
	 */
	currentConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:thisDelegate];  
	if (currentConnection) {
		receivedData=[[NSMutableData data] retain];
	} else {
		// inform the user that the download could not be made
	}
}


- (NSURLConnection*)getAlbumsWithDelegate:(id)thisDelegate {
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:fullURL
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:60.0];
    [theRequest setValue:@"WebAlbums" forHTTPHeaderField:@"User-Agent"];
    [theRequest setHTTPMethod:@"POST"];
    NSString *requestString = @"cmd=fetch-albums&protocol_version=2.1";
	
	if (type == GalleryTypeG2) 
		requestString = @"g2_controller=remote:GalleryRemote&g2_form[cmd]=fetch-albums-prune&g2_form[protocol_version]=2.3";
	
    NSData *requestData = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    [theRequest setHTTPBody:requestData];
   /* 
    currentConnection = [ZWURLConnection connectionWithRequest:theRequest];
    while ([currentConnection isRunning]) 
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    
    if ([currentConnection isCancelled]) 
        return ZW_GALLERY_OPERATION_DID_CANCEL;

    NSData *data = [currentConnection data];
    
    if (data == nil) 
        return ZW_GALLERY_COULD_NOT_CONNECT;
	NSLog(@"Got some data %@", data);
*/
	return [[NSURLConnection alloc] initWithRequest:theRequest delegate:thisDelegate];  
}


-(void) processAlbums:(NSDictionary*)response {	
    if (response == nil) 
        return;
    
    ZWGalleryRemoteStatusCode status = (ZWGalleryRemoteStatusCode)[[response objectForKey:@"statusCode"] intValue];
        
    [albums release];
    albums = nil;
    
    if (status != GR_STAT_SUCCESS)
        return;
    
    // add the albums to myself here...
    int numAlbums = [[response objectForKey:@"album_count"] intValue];
    NSMutableArray *galleriesArray = [NSMutableArray array];
    [galleriesArray addObject:[ZWGalleryAlbum albumWithTitle:@"" name:@"" gallery:self]];
    int i;
    // first we'll iterate through to create the objects, since we don't know if they'll be in an order
    // where parents will always come before children
    for (i = 1; i <= numAlbums; i++) {
        NSString *a_name = [response objectForKey:[NSString stringWithFormat:@"album.name.%i", i]];
        NSString *a_title = [response objectForKey:[NSString stringWithFormat:@"album.title.%i", i]];
        ZWGalleryAlbum *album = [ZWGalleryAlbum albumWithTitle:a_title name:a_name gallery:self];

        // this album will use the delegate of the gallery we're on
        [album setDelegate:[self delegate]];
        
        BOOL a_can_add = NO;
        if ([[response objectForKey:[NSString stringWithFormat:@"album.perms.add.%i", i]] isEqual:@"true"]) {
            a_can_add = YES;
        }
        [album setCanAddItem:a_can_add];
        BOOL a_can_create_sub = NO;
        if ([[response objectForKey:[NSString stringWithFormat:@"album.perms.create_sub.%i", i]] isEqual:@"true"]) {
            a_can_create_sub = YES;
        }
        [album setCanAddSubAlbum:a_can_create_sub];
        [galleriesArray addObject:album];
    }
	
    // now iterate through setting the parents
	// We used to be able to rely on the ids being sequential integers starting at 1. Starting with G2,
	// we can't make that assumption anymore so this has to be a little more complicated.
    for (i = 1; i <= numAlbums; i++) { 
        int album_parent_id = [[response objectForKey:[NSString stringWithFormat:@"album.parent.%i", i]] intValue];
		ZWGalleryAlbum *album = [galleriesArray objectAtIndex:i];
		
        if (album_parent_id) {
            if ([self type] == GalleryTypeG1) {
                // For G1, the parent field is referring back to the item at that index in the list we got.
                ZWGalleryAlbum *parent = [galleriesArray objectAtIndex:album_parent_id];
                
                [album setParent:parent];
                [parent addChild:album];
            }
            else if ([self type] == GalleryTypeG2) {
                // For G2, the parent id is actually referring to the "name", so we have to iterate to find it
                int j;
                for (j = 1; j <= numAlbums; j++) {
                    int this_parent_id = [[response objectForKey:[NSString stringWithFormat:@"album.name.%i", j]] intValue];
                    
                    if (this_parent_id == album_parent_id) {
                        ZWGalleryAlbum *parentAlbum = [galleriesArray objectAtIndex:j];
                        
                        [album setParent:parentAlbum];
                        [parentAlbum addChild:album];
                    }
                }
            }
            else {
                // Who knows how XMLRPC version does it.
            }
        }
    }
	albums = [[[NSArray alloc] initWithCoder:galleriesArray] retain];
}


- (NSURLConnection*)getItemsforAlbum:(NSString*)thisAlbum withDelegate:(id)thisDelegate {
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:fullURL
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:60.0];
    [theRequest setValue:@"WebAlbums" forHTTPHeaderField:@"User-Agent"];
    [theRequest setHTTPMethod:@"POST"];
    
    NSString *requestString = [NSString stringWithFormat:@"cmd=fetch-album-images&set_albumName=%@&protocol_version=2.1",thisAlbum];
	
	if (type == GalleryTypeG2) 
		requestString = [NSString 
						 stringWithFormat:@"g2_controller=remote:GalleryRemote&g2_form[cmd]=fetch-album-images&g2_form[set_albumName]=%@&g2_form[protocol_version]=2.3",thisAlbum];	
	NSLog(@"Sending request: %@", requestString);
	
    NSData *requestData = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    [theRequest setHTTPBody:requestData];
    
	return [[NSURLConnection alloc] initWithRequest:theRequest delegate:thisDelegate];  
}

- (NSMutableArray*)requestsForPhotos:(NSDictionary*)photos {
	NSMutableArray * requests = [[NSMutableArray alloc] initWithCapacity:[photos count]];
	for (NSInteger i=0; i<[photos count]; i++) {
		NSMutableURLRequest *request;
		[requests addObject:request];
	}
	return requests;
}

- (ZWGalleryRemoteStatusCode)doCreateAlbumWithName:(NSString *)name title:(NSString *)title summary:(NSString *)summary parent:(ZWGalleryAlbum *)parent
{    
    NSString *parentName;
    if (parent != nil && ![parent isKindOfClass:[NSNull class]]) 
        parentName = [parent name];
    else 
        parentName = @"0";  // this might break G2, but new G2 albums all have a parent.
        
    ZWMutableURLRequest *theRequest = [ZWMutableURLRequest requestWithURL:fullURL
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:60.0];
    [theRequest setValue:@"WebAlbums" forHTTPHeaderField:@"User-Agent"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setEncoding:[self sniffedEncoding]];
    [theRequest setVariation:ZSURLMultipartVariation];
    
    if ([self isGalleryV2]) 
        [theRequest addString:@"remote:GalleryRemote" forName:@"g2_controller"];
    
    [theRequest addString:@"new-album" forName:[self formNameWithName:@"cmd"]];
    [theRequest addString:@"2.3" forName:[self formNameWithName:@"protocol_version"]];
    [theRequest addString:parentName forName:[self formNameWithName:@"set_albumName"]];
    [theRequest addString:name forName:[self formNameWithName:@"newAlbumName"]];
    [theRequest addString:title forName:[self formNameWithName:@"newAlbumTitle"]];
    [theRequest addString:summary forName:[self formNameWithName:@"newAlbumDesc"]];
    
    currentConnection = [ZWURLConnection connectionWithRequest:theRequest];
    while ([currentConnection isRunning]) 
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    
    if ([currentConnection isCancelled]) 
        return ZW_GALLERY_OPERATION_DID_CANCEL;
    
    NSData *data = [currentConnection data];
    
    if (data == nil) 
        return ZW_GALLERY_COULD_NOT_CONNECT;
	NSLog(@"Got some data %@", data);

    NSDictionary *galleryResponse = [self parseResponseData:data];
    if (galleryResponse == nil) 
        return ZW_GALLERY_PROTOCOL_ERROR;
    
    ZWGalleryRemoteStatusCode status = (ZWGalleryRemoteStatusCode)[[galleryResponse objectForKey:@"statusCode"] intValue];
    
    if (status == GR_STAT_SUCCESS) {
        [lastCreatedAlbumName release];
        lastCreatedAlbumName = [[galleryResponse objectForKey:@"album_name"] copy];
    }
    
    // TODO: create an actual ZWGalleryAlbum to return?
    return status;
}

@end
