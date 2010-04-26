//
//  WAAccountsViewController.h
//  WebAlbums
//
//  Created by JJL on 6/20/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WAAccountsViewController : UITableViewController {
	
	NSMutableArray *accountsArray;
	NSManagedObjectContext *managedObjectContext;
	UIBarButtonItem *addButton;
	UITableViewController *albumsViewController;

}

@property (nonatomic, retain) NSMutableArray *accountsArray;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) UIBarButtonItem *addButton;
@property (nonatomic, retain) UITableViewController *albumsViewController;

- (void)showAddAccount;

@end
