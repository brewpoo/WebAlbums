//
//  WAFacebook.h
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
