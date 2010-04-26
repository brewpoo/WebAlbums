//
//  WAAlbumsViewController.h
//  WebAlbums
//
//  Created by JJL on 7/9/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WAAccountType.h"
#import "WAAccount.h"

@interface WAAlbumsViewController : UITableViewController <WAAccountDelegate> {
	NSManagedObjectContext *managedObjectContext;
	WAAccountType *accountController;
	WAAccount *account;
	NSArray *albums;
	UITableViewController *photosViewController;
	
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) WAAccountType *accountController;
@property (nonatomic, retain) WAAccount *account;
@property (nonatomic, retain) NSArray *albums;
@property (nonatomic, retain) UITableViewController *photosViewController;

- (id)initWithAccount:(WAAccount*)thisAccount;
- (void)accountAlbumsUpdated;

@end
