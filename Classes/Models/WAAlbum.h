//
//  WAAlbum.h
//  WebAlbums
//
//  Created by JJL on 6/20/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <CoreData/CoreData.h>

@class WAAccount;

@interface WAAlbum :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) WAAccount * account;

@end



