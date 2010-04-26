//
//  WAAlbumsViewController.m
//  WebAlbums
//
//  Created by JJL on 7/9/09.
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


#import "WAAlbumsViewController.h"
#import "WAPhotosListViewController.h"
#import "WAAccount.h"
#import "WAAlbum.h"

#import "WAAccountType.h"
#import "WAFacebook.h"
#import "WAPicasa.h"
#import "WAGallery.h"

@implementation WAAlbumsViewController

@synthesize managedObjectContext;
@synthesize accountController;
@synthesize account;
@synthesize albums;
@synthesize photosViewController;

- (id)initWithAccount:(WAAccount*)thisAccount {
	self = [super initWithStyle:UITableViewStylePlain];
	managedObjectContext = thisAccount.managedObjectContext;
	account = thisAccount;
	account.delegate = self;
	if ([account.accountType isEqualToString:@"facebook"]) {
		accountController = [[[WAFacebook alloc] initWithAccount:account] retain];
	} else if ([account.accountType isEqualToString:@"picasa"]) {
		accountController = [[[WAPicasa alloc] initWithAccount:account] retain];
	} else if ([account.accountType isEqualToString:@"gallery"]) {
		accountController = [[[WAGallery alloc] initWithAccount:account] retain];
	}
#ifdef DEBUG
	NSLog(@"Account: %@ Account Controller: %@", account, accountController);
#endif
	// Need to catch and display error if this fails
	[accountController establishConnection];
	return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/



- (void)updateDataSource {
	[managedObjectContext refreshObject:account mergeChanges:YES];

	NSSortDescriptor *nameSort;
	if ([account.accountType isEqualToString:@"gallery"]) {
		nameSort = [[[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES
												 selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];

	} else {
		nameSort =[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES 
												selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
	}
	
	NSArray *temp  = [account.albums allObjects];
	if (albums) {
		[albums autorelease];
	}
	albums = [temp sortedArrayUsingDescriptors:[NSArray arrayWithObjects:nameSort, nil]];
	[albums retain];
	[self.tableView reloadData];
}

- (void)accountAlbumsUpdated {
#ifdef DEBUG
	NSLog(@"Updated album data");
#endif

	[self updateDataSource];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = account.name;
	// Add toolbar with reload button to refresh account list?
}


- (void)viewWillAppear:(BOOL)animated {
	[self updateDataSource];
    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [albums count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Album";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Potentially Add subtitle and album thumbnail (settings controllable)
	WAAlbum *album = [albums objectAtIndex:indexPath.row];
	if (album.cachedCount == 0 | album.cachedCount == nil) {
		cell.textLabel.text = album.name;
	} else {
		cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", album.name, album.cachedCount];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
	cell.indentationLevel = [album depth];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	// Don't flash the cell
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	WAAlbum *album = [albums objectAtIndex:indexPath.row];
	photosViewController = [[[WAPhotosListViewController alloc] initWithAccountController:accountController andAlbum:album] retain];
	[self.navigationController pushViewController:photosViewController animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[managedObjectContext release];
	[accountController release];
	[account release];
	[albums release];
	[photosViewController release];
    [super dealloc];
}


@end

