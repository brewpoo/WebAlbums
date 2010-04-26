//
//  WAGallery.h
//  WebAlbums
//
//  Created by JJL on 6/20/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WAAccountType.h"
#import "WAMultipleDownload.h"
#import "ZWGallery.h"

@interface WAGallery : WAAccountType {
	ZWGallery * gallery;
	NSURLConnection * currentConnection;
	NSMutableData * receivedData;
	WAMultipleDownload * downloads;
	NSNumber * currentAlbum;
}

@property (nonatomic, retain) ZWGallery *gallery;
@property (nonatomic, retain) NSURLConnection *currentConnection;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) WAMultipleDownload * downloads;
@property (nonatomic, retain) NSNumber * currentAlbum;

-(void)establishConnection;
-(void)getAlbums;
-(void)getPhotosForAlbum:(WAAlbum*)album;

@end
