//
//  WAFacebook.h
//  WebAlbums
//
//  Created by JJL on 6/20/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WAAccountType.h"
#import "WAAccount.h"
#import "WAAlbum.h"
#import "FBConnect/FBConnect.h"

@interface WAFacebook : WAAccountType <FBSessionDelegate, FBRequestDelegate> {
	FBSession *session;
}

@property (nonatomic, retain) FBSession *session;

-(void)establishConnection;
-(void)getAlbums;
-(void)getPhotosForAlbum:(WAAlbum*)album;
//-(id)getPhoto;

- (void)dealloc;

@end
