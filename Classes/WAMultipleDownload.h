//
//  WAMultipleDownload.h
//
//  Copyright 2008 Stepcase Limited.
//

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
