//
//  WASettingsViewController.m
//  WebAlbums
//
//  Created by JJL on 6/20/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

/*
 
 Accounts
 
Newest Photos First Yes/No
Photo List Yes/No
 
 
 */

#import "WASettingsViewController.h"
#import "WebAlbumsAppDelegate.h"
#import "WAAccount.h"

#import "WAAddPicasaViewController.h"
#import "WAAddGalleryViewController.h"
#import "WAAddFacebookViewController.h"
#import "WAAddGenericViewController.h"

@implementation WASettingsViewController

@synthesize accountsArray;
@synthesize managedObjectContext;
@synthesize modalViewController;

- (void)fetchAccounts {	// Setup CoreData connection and get all accounts
	NSManagedObjectContext *moc = [self managedObjectContext]; 
	NSEntityDescription *entityDescription = [NSEntityDescription 
											  entityForName:@"Account" inManagedObjectContext:moc]; 
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease]; 
	[request setEntity:entityDescription]; 
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] 
										initWithKey:@"name" ascending:YES]; 
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]]; 
	[sortDescriptor release]; 
	NSError *error; 
	accountsArray = [[[NSMutableArray alloc] initWithArray:[moc executeFetchRequest:request error:&error]] retain]; 
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self fetchAccounts];
		
}

- (void)viewWillAppear:(BOOL)animated {
	[self fetchAccounts];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { 
    return 2; 
} 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
	if (section==0) {
		return [accountsArray count]; 
	} else {
		return 2;
	}
} 

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section==0) {
		return @"Accounts";
	} else if (section==1) {
		return @"Photo Settings";
	}
	return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath { 
    static NSString *identifier = @"Account"; 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier]; 
    if (cell == nil) { 
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
									   reuseIdentifier:identifier] autorelease]; 
    } 
	if (indexPath.section == 0) {
		WAAccount *account = [accountsArray objectAtIndex:indexPath.row]; 
		cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@Icon.png", account.accountType]];
		cell.textLabel.text = account.name; 
		if ([account.isEnabled boolValue]==YES) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	} else {
		if (indexPath.section == 1 & indexPath.row == 0) {
			// Switch for sort order
			UISwitch *sortOrderSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(200, 10, 100, 40)];
			[sortOrderSwitch addTarget:self action:@selector(sortOrderUpdated:)
						  forControlEvents:(UIControlEventValueChanged | UIControlEventTouchDragInside)];	

			sortOrderSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"photosNewestFirst"] boolValue];
			
			cell.textLabel.text = @"Sort Newest First";
			[cell addSubview:sortOrderSwitch];
			
		} else if (indexPath.section == 1 & indexPath.row == 1) {
			// Switch for new photo indicator
			UISwitch *newPhotoSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(200, 10, 100, 40)];
			[newPhotoSwitch addTarget:self action:@selector(newPhotoUpdated:)
					  forControlEvents:(UIControlEventValueChanged | UIControlEventTouchDragInside)];	
			
			newPhotoSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"markNewPhotos"] boolValue];
			
			cell.textLabel.text = @"Mark New Photos";
			[cell addSubview:newPhotoSwitch];
		}
	}
    return cell; 
} 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	if (indexPath.section == 0) {
		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
		NSEntityDescription *entity =
		[NSEntityDescription entityForName:@"Account"
				inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];
	
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self == %@", [[accountsArray objectAtIndex:indexPath.row] objectID]];
		[request setPredicate:predicate];
	
		NSError *error;
		WAAccount *account =[[managedObjectContext executeFetchRequest:request error:&error] objectAtIndex:0];

		NSLog(@"Account selected %@", account);
	
		if ([account.accountType isEqualToString:@"picasa"]) {
#ifdef DEBUG
			NSLog(@"Edit Picasa account selected");
#endif
			modalViewController = [[[WAAddPicasaViewController alloc] initWithAccount:account] autorelease];
		} else if ([account.accountType isEqualToString:@"facebook"]) {
#ifdef DEBUG
			NSLog(@"Edit Facebook account selected");
#endif
			modalViewController = [[[WAAddFacebookViewController alloc] initWithAccount:account] autorelease]; 
		} else if ([account.accountType isEqualToString:@"gallery"]) {
#ifdef DEBUG
			NSLog(@"Edit Gallery account selected");
#endif
			modalViewController = [[[WAAddGalleryViewController alloc] initWithAccount:account] autorelease];
		} else if ([account.accountType isEqualToString:@"generic"]) {
#ifdef DEBUG
			NSLog(@"Edit Generic URL account selected");
#endif
			modalViewController = [[[WAAddGenericViewController alloc] initWithAccount:account] autorelease];
		} 
		UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:modalViewController];
		[self.navigationController presentModalViewController:modalNavController animated:YES];
		//[self.navigationController popViewControllerAnimated:YES];
		[modalNavController release];
	} else {
		// Do nothing?
	}
}

- (void)sortOrderUpdated:(UISwitch *)sender {
	NSLog(@"Sort Order Updated");
	if (sender.on) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"photosNewestFirst"];
	} else {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"photosNewestFirst"];
	}
}

- (void)newPhotoUpdated:(UISwitch *)sender {
	NSLog(@"Mark New Photosr Updated");
	if (sender.on) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"markNewPhotos"];
	} else {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"markNewPhotos"];
	}
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        // Custom initialization   
	}
    return self;
}
 */




// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
#ifdef DEBUG 
	NSLog(@"Loaded WASettingsViewController");
#endif
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[modalViewController release];
	[accountsArray release];
	[managedObjectContext release];
    [super dealloc];
}


@end
