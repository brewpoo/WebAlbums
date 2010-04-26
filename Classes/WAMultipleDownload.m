//
//  WAMultipleDownload.m
//
//  Copyright 2008 Stepcase Limited.
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


#import "WAMultipleDownload.h"


@implementation WAMultipleDownload

@synthesize urls, requests, receivedDatas, finishCount;

- init {
    if ((self = [super init])) {
		self.finishCount = 0;
		NSMutableArray *array = [[NSMutableArray alloc] init];
		self.receivedDatas = array;
		[array release];
		
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		self.requests = dict;
		[dict release];

    }
    return self;
}

- (void)dealloc {
	[urls release];
	[requests release];
	[receivedDatas autorelease];
    [super dealloc];
}

- (void)setDelegate:(id)val
{
    delegate = val;
}

- (id)delegate
{
    return delegate;
}


#pragma mark Methods
- (id)initWithUrls:(NSArray *)aUrls {
    if ((self = [self init]))
		[self requestWithUrls:aUrls];
	return self;
}

- (id)initWithRequests:(NSArray *)aRequests {
	if ((self = [self init]))
		[self requestWithRequests:aRequests];
	return self;
}

- (void)requestWithRequests:(NSArray *)aRequests {
	[receivedDatas removeAllObjects];
	[requests removeAllObjects];
	
	for(NSInteger i=0; i<[aRequests count]; i++) {
		NSMutableData *aData = [[NSMutableData alloc] init];
		[receivedDatas addObject:aData];
		[aData release];
		
		NSURLConnection *connection = [[NSURLConnection alloc]
									   initWithRequest:[aRequests objectAtIndex:i]
									   delegate:self];
		[requests setObject: [NSNumber numberWithInt: i] forKey: [NSValue valueWithNonretainedObject:connection]];
		[connection release];
	}
}

- (void)requestWithUrls:(NSArray *)aUrls {

	[receivedDatas removeAllObjects];
	[requests removeAllObjects];
	[urls autorelease];
	urls = [aUrls copy];
	
	for(NSInteger i=0; i< [urls count]; i++){
		NSMutableData *aData = [[NSMutableData alloc] init];
		[receivedDatas addObject: aData];
		[aData release];
		
		NSURLRequest *request = [[NSURLRequest alloc] 
								 initWithURL: [NSURL URLWithString: [urls objectAtIndex:i]]
								 cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
								 timeoutInterval: 10
								 ];
		NSURLConnection *connection = [[NSURLConnection alloc]
									   initWithRequest:request
									   delegate:self];
		
		[requests setObject: [NSNumber numberWithInt: i] forKey: [NSValue valueWithNonretainedObject:connection]];
		[connection release];
		[request release];	
	}
}

- (NSData *)dataAtIndex:(NSInteger)idx {
	return [receivedDatas objectAtIndex:idx];
}

- (NSString *)dataAsStringAtIndex:(NSInteger)idx {
	return [[[NSString alloc] initWithData:[receivedDatas objectAtIndex:idx] encoding:NSUTF8StringEncoding] autorelease];
}

#pragma mark NSURLConnection Delegates
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSInteger i = [[requests objectForKey: [NSValue valueWithNonretainedObject:connection]] intValue];
    [[receivedDatas objectAtIndex:i] setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSInteger i = [[requests objectForKey: [NSValue valueWithNonretainedObject:connection]] intValue];
    [[receivedDatas objectAtIndex:i] appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSInteger i = [[requests objectForKey: [NSValue valueWithNonretainedObject:connection]] intValue];
	finishCount++;
	
	if ([delegate respondsToSelector:@selector(didFinishDownload:)])
        [delegate performSelector:@selector(didFinishDownload:) withObject: [NSNumber numberWithInt: i]];
	
	if(finishCount >= [urls count]){
		if ([delegate respondsToSelector:@selector(didFinishAllDownload)])
			[delegate didFinishAllDownload];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if ([delegate respondsToSelector:@selector(didFailDownloadWithError:)])
        [delegate performSelector:@selector(didFailDownloadWithError:) withObject: error];
}

@end
