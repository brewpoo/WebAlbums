//
//  WAAccountType.h
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
#import "WAAccount.h"
#import "WAAlbum.h"

@interface WAAccountType : NSObject {
	NSString *name;
	NSString *identifier;
	NSString *image;
	
	WAAccount *account;
}


@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) WAAccount *account;

+ (NSArray *)listAccountTypes;

+ (BOOL)validate:(id)account;
- (void)establishConnection;
- (void)getPhotosForAlbum:(WAAlbum*)album;


@end
