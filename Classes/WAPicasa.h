//
//  WAPicasa.h
//  WebAlbums
//
//  Created by JJL on 6/22/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WAAccountType.h"
#import "GDataPhotos.h"


@interface WAPicasa : WAAccountType {
	GDataServiceGooglePhotos *service; // user feed of album entries
}

@property (nonatomic, retain) GDataServiceGooglePhotos *service;

-(void)establishConnection;
-(void)getAlbums;
-(void)getPhotosForAlbum:(WAAlbum*)album;

- (GDataServiceGooglePhotos *)googlePhotosService;
@end
