//
//  WASettingsViewController.h
//  WebAlbums
//
//  Created by JJL on 6/20/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WASettingsViewController : UITableViewController {
	NSMutableArray *accountsArray;
	NSManagedObjectContext *managedObjectContext;
	UIViewController *modalViewController;


}

@property (nonatomic,retain) NSMutableArray *accountsArray;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) UIViewController *modalViewController;

@end
