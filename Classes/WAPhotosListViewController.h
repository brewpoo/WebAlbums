//
//  WAPhotosListViewController.h
//  WebAlbums
//
//  Created by JJL on 7/15/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WAAlbum.h"
#import "WAAccount.h"
#import "WAAccountType.h"


@interface WAPhotosListViewController : UITableViewController <WAAccountDelegate> {
	NSManagedObjectContext *managedObjectContext;
	WAAlbum *album;
	WAAccount *account;
	NSArray *photos;
	UIViewController *photoDetailViewController;
	WAAccountType *accountController;
	
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) WAAlbum *album;
@property (nonatomic, retain) WAAccount *account;
@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, retain) UIViewController *photoDetailViewController;
@property (nonatomic, retain) WAAccountType *accountController;

- (id)initWithAccountController:(WAAccountType*)thisController andAlbum:(WAAlbum*)thisAlbum;
- (void)albumPhotosUpdated;

@end
