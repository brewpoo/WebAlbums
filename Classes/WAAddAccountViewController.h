//
//  WAAddAccountViewController.h
//  WebAlbums
//
//  Created by JJL on 6/20/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WAAddAccountViewController : UITableViewController {
    NSManagedObjectContext *managedObjectContext; 
	
	NSMutableArray *accountTypeArray;
	UIViewController *modalViewController;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *accountTypeArray;
@property (nonatomic, retain) UIViewController *modalViewController;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)moc;

@end
