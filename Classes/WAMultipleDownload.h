//
//  WAMultipleDownload.h
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


#import <UIKit/UIKit.h>


@interface WAMultipleDownload : NSObject {
	NSMutableArray *urls;
	NSMutableDictionary *requests;
	NSMutableArray *receivedDatas;
	NSInteger finishCount;
	id delegate;
}

@property (nonatomic,retain) NSMutableArray *urls;
@property (nonatomic,retain) NSMutableDictionary *requests;
@property (nonatomic,retain) NSMutableArray *receivedDatas;
@property NSInteger finishCount;
@property (retain) id delegate;

- (id)initWithUrls:(NSArray *)aUrls;
- (id)initWithRequests:(NSArray *)aRequests;
- (void)requestWithUrls:(NSArray *)aUrls;
- (void)requestWithRequests:(NSArray *)aRequests;
- (NSData *)dataAtIndex:(NSInteger)idx;
- (NSString *)dataAsStringAtIndex:(NSInteger)idx;
- (void)setDelegate:(id)val;
- (id)delegate;

@end

@interface NSObject (MultipleDownloadDelegateMethods)

- (void)didFinishDownload:(NSNumber*)idx;
- (void)didFinishAllDownload;

@end
