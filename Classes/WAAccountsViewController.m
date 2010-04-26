//
//  WAAccountsViewController.m
//  WebAlbums
//
//  Created by JJL on 6/20/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import "WAAccountsViewController.h"
#import "WAAddAccountViewController.h"
#import "WAAlbumsViewController.h"
#import "WAAccount.h"


@implementation WAAccountsViewController

@synthesize accountsArray;
@synthesize managedObjectContext;
@synthesize addButton;
@synthesize albumsViewController;

- (void)fetchAccounts {	// Setup CoreData connection and get all accounts
	NSManagedObjectContext *moc = [self managedObjectContext]; 
	NSEntityDescription *entityDescription = [NSEntityDescription 
											  entityForName:@"Account" inManagedObjectContext:moc]; 
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease]; 
	[request setEntity:entityDescription]; 
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isEnabled=1"];
	[request setPredicate:predicate];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] 
										initWithKey:@"name" ascending:YES]; 
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]]; 
	[sortDescriptor release]; 
	NSError *error; 
	accountsArray = [[[NSMutableArray alloc] initWithArray:[moc executeFetchRequest:request error:&error]] retain]; 
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
    addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
															  target:self action:@selector(showAddAccount)];
	
    addButton.enabled = YES;
	self.navigationItem.rightBarButtonItem = addButton;
	
	[self fetchAccounts];

	if ([accountsArray count]==0) { [self showAddAccount]; }

}

- (void)viewWillAppear:(BOOL)animated {
	[self fetchAccounts];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { 
    return 1; 
} 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
	return [accountsArray count]; 
} 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath { 
    static NSString *identifier = @"Account"; 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier]; 
    if (cell == nil) { 
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
									   reuseIdentifier:identifier] autorelease]; 
    } 
    WAAccount *account = [accountsArray objectAtIndex:indexPath.row]; 
	cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@Icon.png", account.accountType]];
    cell.textLabel.text = account.name; 
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
    return cell; 
} 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	// Don't flash the cell
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	WAAccount *account = [accountsArray objectAtIndex:indexPath.row];
	albumsViewController = [[[WAAlbumsViewController alloc] initWithAccount:account] retain];
	[self.navigationController pushViewController:albumsViewController animated:YES];

}


- (void)showAddAccount {	
	[self.navigationController pushViewController:[[WAAddAccountViewController alloc] initWithManagedObjectContext:managedObjectContext] animated:YES];
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
#ifdef DEBUG
	NSLog(@"Loaded WAAccountsViewController");
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
	self.accountsArray = nil;
	self.addButton = nil;
}


- (void)dealloc {
	[albumsViewController release];
	[accountsArray release];
	[addButton release];
	[managedObjectContext release];
    [super dealloc];
}


@end
