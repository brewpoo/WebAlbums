//
//  WAAddAccountViewController.m
//  WebAlbums
//
//  Created by JJL on 6/20/09.
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


#import "WAAddAccountViewController.h"
#import "WebAlbumsAppDelegate.h"
#import "WAAccountType.h"
#import "WAAccount.h"

#import "WAAddPicasaViewController.h"
#import "WAAddFacebookViewController.h"
#import "WAAddGalleryViewController.h"
#import "WAAddGenericViewController.h"


@implementation WAAddAccountViewController

@synthesize managedObjectContext;
@synthesize accountTypeArray;
@synthesize modalViewController;

- (id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
	}
	return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)moc {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
	}
	self.managedObjectContext = moc;
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.rowHeight = 80.0;
	self.navigationItem.title = @"Add Account...";
	accountTypeArray = [[NSMutableArray alloc] initWithArray:[WAAccountType listAccountTypes]];
}



- (void)viewWillAppear:(BOOL)animated {
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

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
    return [accountTypeArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"AccountCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	// Use associated image or text if none esists
	WAAccountType *account = [accountTypeArray objectAtIndex:indexPath.row];
	if ([account image]) {
		cell.imageView.image = [UIImage imageNamed:[account image]];
	} else {
		cell.textLabel.text = [account name];
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];

	// Don't flash the cell
	[tableView deselectRowAtIndexPath:indexPath animated:NO];

	NSString *flag = [[accountTypeArray objectAtIndex:indexPath.row] identifier];
	WAAccount *account = (WAAccount *)[NSEntityDescription 
									   insertNewObjectForEntityForName:@"Account" 
									   inManagedObjectContext:managedObjectContext];
	account.isNew = [NSNumber numberWithInt:1];
	if ([flag isEqualToString:@"picasa"]) {
#ifdef DEBUG
		NSLog(@"Add Picasa account selected");
#endif
		account.accountType = @"picasa";
		account.requiresLogin = [NSNumber numberWithBool:YES];
		modalViewController = [[[WAAddPicasaViewController alloc] initWithAccount:account] autorelease];
	} else if ([flag isEqualToString:@"facebook"]) {
#ifdef DEBUG
		NSLog(@"Add Facebook account selected");
#endif
		account.accountType = @"facebook";
		account.requiresLogin = [NSNumber numberWithBool:YES];
		modalViewController = [[[WAAddFacebookViewController alloc] initWithAccount:account] autorelease]; 
	} else if ([flag isEqualToString:@"gallery"]) {
#ifdef DEBUG
		NSLog(@"Add Gallery account selected");
#endif
		account.accountType = @"gallery";
		account.requiresLogin = [NSNumber numberWithBool:NO];
		modalViewController = [[[WAAddGalleryViewController alloc] initWithAccount:account] autorelease];
	} else if ([flag isEqualToString:@"generic"]) {
#ifdef DEBUG
		NSLog(@"Add Generic URL account selected");
		account.accountType = @"generic";
		account.requiresLogin = [NSNumber numberWithBool:NO];
		modalViewController = [[[WAAddGenericViewController alloc] initWithAccount:account] autorelease];
#endif
	} 
	UINavigationController *modalNavController = [[UINavigationController alloc] initWithRootViewController:modalViewController];
	[self.navigationController presentModalViewController:modalNavController animated:YES];
	[self.navigationController popViewControllerAnimated:YES];
	[modalNavController release];
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



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}



- (void)dealloc {
	[managedObjectContext release];
	//[modalViewController release];
	[accountTypeArray release];
    [super dealloc];
}


@end

