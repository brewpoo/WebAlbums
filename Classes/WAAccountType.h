//
//  WAAccountType.h
//  WebAlbums
//
//  Created by JJL on 6/20/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

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
