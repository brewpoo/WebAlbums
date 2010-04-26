//
//  WAGallery.h
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
