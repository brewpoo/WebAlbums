//
//  WAAccountFormViewController.m
//  WebAlbums
//
//  Created by JJL on 6/22/09.
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

#import "WAAccountFormViewController.h"
#import "WATableFormControl.h"
#import "WATableFormSection.h"

#import "WAAccount.h"
#import "WAGallery.h"
#import "WAFacebook.h"
#import "WAPicasa.h"
#import "WAGenericUrl.h"

#import "WebAlbumsAppDelegate.h"


@implementation WAAccountFormViewController

@synthesize cancelButton;
@synthesize saveButton;
@synthesize loginRequiredElement;
@synthesize accountNameElement;
@synthesize userNameElement;
@synthesize passWordElement;
@synthesize emailElement;
@synthesize accountUrlElement;
@synthesize sections;
@synthesize account;
@synthesize deleteButton;

#define _accountEnabledElement	1
#define _accountUrlElement		2
#define _loginRequiredElement	3
#define _userNameElement		4
#define _passWordElement		5
#define _emailElement			6
#define _accountNameElement		7

#define newAccount [account.isNew integerValue]==1
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
	}
	return self;
}

- (id)initWithAccount:(WAAccount *)fromAccount {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
	}
	account = fromAccount;
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																 target:self action:@selector(cancelAccount)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
															   target:self action:@selector(saveAccount)];
	if ([account.isNew integerValue]==1) {
		[saveButton setEnabled:NO];
	}
	// Disable save button unless valid object
	self.navigationItem.rightBarButtonItem = saveButton;
	
	// Initialize sections array
	sections = [[[NSMutableArray alloc] init] retain];

	// Setup account eanble section (always available)
	WATableFormSection *section0 = [[WATableFormSection alloc] init];
	
	// Add enabled/disable switch
	UISwitch *accountEnabled = [[UISwitch alloc] initWithFrame:CGRectMake(200, 10, 20.0, 20.0)];
	accountEnabled.on = YES;
	if([account.isNew integerValue]!=1) { accountEnabled.on=[account.isEnabled boolValue]; }
	accountEnabled.tag = _accountEnabledElement;
	[accountEnabled addTarget:self action:@selector(accountEnabledUpdated:) forControlEvents:(UIControlEventValueChanged | UIControlEventTouchDragInside)];
	WATableFormControl *accountEnabledElement = [[WATableFormControl alloc] init];
	[accountEnabledElement addControl:accountEnabled];
	accountEnabledElement.label = @"Account";
	[section0.elements addObject:accountEnabledElement];
	[sections addObject:section0];
	[section0 release];
	[accountEnabled release];
	[accountEnabledElement release];
	
	// Next section account nick name
	WATableFormSection *section1 = [[WATableFormSection alloc] init];
	
	UITextField *accountNameField = [[UITextField alloc] initWithFrame:CGRectMake(80, 10, 200, 40)];
	[accountNameField addTarget:self action:@selector(accountNameUpdated:) 
			   forControlEvents:(UIControlEventEditingDidEnd)];
	accountNameField.delegate = self;
	accountNameField.returnKeyType = UIReturnKeyDone;
	accountNameField.tag = _accountNameElement;
	if([account.isNew integerValue]!=1) { accountNameField.text = account.name; }
	accountNameElement = [[WATableFormControl alloc] init];
	[accountNameElement addControl:accountNameField];
	accountNameElement.label = @"Name";
	[section1.elements addObject:accountNameElement];
	section1.sectionHeader = @"Account Nickname";
	[sections addObject:section1];
	[section1 release];
	[accountNameField release];
	[accountNameElement release];

	// Setup default form elements for use by sublcass controllers
	UITextField *accountUrlField = [[UITextField alloc] initWithFrame:CGRectMake(80, 10, 200, 40)];
	[accountUrlField addTarget:self action:@selector(accountUrlUpdated:) 
		 forControlEvents:(UIControlEventEditingDidEnd)];
	accountUrlField.placeholder = @"http://example.com/";
	accountUrlField.delegate = self;
	accountUrlField.autocorrectionType = UITextAutocorrectionTypeNo;
	accountUrlField.returnKeyType = UIReturnKeyDone;
	accountUrlField.tag = _accountUrlElement;
	if([account.isNew integerValue]!=1) { accountUrlField.text = account.url; }
	accountUrlElement = [[WATableFormControl alloc] init];
	[accountUrlElement addControl:accountUrlField];
	accountUrlElement.label = @"URL";
	[accountUrlField release];
	
	UISwitch *loginRequiredSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(200, 10, 100, 40)];
	[loginRequiredSwitch addTarget:self action:@selector(loginRequiredUpdated:)
			forControlEvents:(UIControlEventValueChanged | UIControlEventTouchDragInside)];	
	loginRequiredSwitch.tag = _loginRequiredElement;
	if([account.isNew integerValue]!=1) { loginRequiredSwitch.on=[account.requiresLogin boolValue]; }
	loginRequiredElement = [[WATableFormControl alloc] init];
	[loginRequiredElement addControl:loginRequiredSwitch];
	loginRequiredElement.label = @"Requires Login";
	[loginRequiredSwitch release];
	
	// Section 3 - Username and Password
	UITextField *userNameField = [[UITextField alloc] initWithFrame:CGRectMake(120, 10, 200, 40)];
	[userNameField addTarget:self action:@selector(userNameUpdated:) forControlEvents:(UIControlEventEditingDidEnd)];
	userNameField.placeholder = @"Username";
	userNameField.delegate = self;
	userNameField.returnKeyType = UIReturnKeyDone;
	userNameField.autocorrectionType = UITextAutocorrectionTypeNo;
	userNameField.tag = _userNameElement;
	if([account.isNew integerValue]!=1) { userNameField.text = account.username; }
	userNameElement = [[WATableFormControl alloc] init];
	[userNameElement addControl:userNameField];
	userNameElement.label = @"Username";
	[userNameField release];
	
	UITextField *passWordField = [[UITextField alloc] initWithFrame:CGRectMake(120, 10, 200,30)];
	[passWordField addTarget:self action:@selector(passWordUpdated:) forControlEvents:(UIControlEventEditingDidEnd)];
	passWordField.placeholder = @"Password";
	passWordField.delegate = self;
	passWordField.autocorrectionType = UITextAutocorrectionTypeNo;
	passWordField.secureTextEntry = TRUE;
	passWordField.returnKeyType = UIReturnKeyDone;
	passWordField.tag = _passWordElement;
	if(!newAccount && [account.requiresLogin boolValue]==YES) { 
		account.formPassword = [account fetchPassword];
		passWordField.text = account.formPassword;
	}
	passWordElement = [[WATableFormControl alloc] init];
	[passWordElement addControl:passWordField];
	passWordElement.label = @"Password";
	[passWordField release];
	
	UITextField *emailField = [[UITextField alloc] initWithFrame:CGRectMake(120, 10, 200, 40)];
	[emailField addTarget:self action:@selector(emailUpdated:) forControlEvents:(UIControlEventEditingDidEnd)];
	emailField.placeholder = @"john@example.com";
	emailField.delegate = self;
	emailField.returnKeyType = UIReturnKeyDone;
	emailField.autocorrectionType = UITextAutocorrectionTypeNo;
	emailField.tag = _emailElement;
	if([account.isNew integerValue]!=1) { emailField.text = account.username; }
	emailElement = [[WATableFormControl alloc] init];
	[emailElement addControl:emailField];
	emailElement.label = @"Email";
	[emailField release];
	
	deleteButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
	deleteButton.frame = CGRectMake(self.tableView.bounds.origin.x+20,150,
									self.tableView.bounds.size.width-40, 40);
	//[deleteButton setButtonType:UIButtonTypeRoundedRect];
	[deleteButton setTitle:@"Delete Account" forState:UIControlStateNormal];
	[deleteButton addTarget:self action:@selector(deleteAccount) forControlEvents:UIControlEventTouchUpInside];
	
	if (!newAccount) {
		self.tableView.tableFooterView.userInteractionEnabled = YES;
		self.tableView.tableFooterView = deleteButton;
	}
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sections count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[sections objectAtIndex:section] elements] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [[sections objectAtIndex:section] sectionHeader];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"account";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	WATableFormControl *element = [[[sections objectAtIndex:indexPath.section] elements] objectAtIndex:indexPath.row];

    

	cell.textLabel.text = element.label;
	cell.accessoryView = nil;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	[cell addSubview:element.control];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
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


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

# pragma mark Keyboard handling
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	[theTextField resignFirstResponder];
	return YES;
}


#pragma mark Control and Button actions

- (void)cancelAccount {
	NSManagedObjectContext *moc = account.managedObjectContext;
	if ([account.isNew integerValue]==1) {
		[moc deleteObject:account];
	} else {
		//undo changes
		[moc rollback];
	}
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)saveAccount {
	NSManagedObjectContext *moc = account.managedObjectContext;
	//[moc insertObject:account];
	if ([account.requiresLogin boolValue]==YES) { 
		[account savePassword:account.formPassword];
	}
	NSError *error; 
	BOOL saved = [moc save:&error];
	NSLog(@"Saving object");
	if (!saved) {
		// Display validation error
		NSLog(@"Save failed");
	} else {
		// Refresh data source
		[self.navigationController dismissModalViewControllerAnimated:YES];
	}
}

- (void)deleteAccount {
#ifdef DEBUG
	NSLog(@"Delete Clicked");
#endif
	UIActionSheet *confirmDelete = [[UIActionSheet alloc] initWithTitle:@"Confirm Delete?"
					delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
	[confirmDelete showInView:self.navigationController.view];
	[confirmDelete release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSManagedObjectContext *moc = account.managedObjectContext;
		if (buttonIndex == 0) {
		// Delete Confirmed
		[moc deleteObject:account];
		[self.navigationController dismissModalViewControllerAnimated:YES];
	} 
}
	
- (void)userNameUpdated:(UITextField *)sender {
	NSLog(@"Username Update");
	account.username = sender.text;
	[self enableSaveIfValid];
}

- (void)passWordUpdated:(UITextField *)sender {
	NSLog(@"Password Updated");
	//Save Password to keychain here
	account.formPassword = sender.text;
	[self enableSaveIfValid];
}

- (void)accountNameUpdated:(UITextField *)sender {
	NSLog(@"Account Name Updated");
	account.name = sender.text;
	[self enableSaveIfValid];
}

- (void)accountEnabledUpdated:(UISwitch *)sender {
	NSLog(@"Account enabled changed");
	if (sender.on) {
		account.isEnabled = [NSNumber numberWithBool:TRUE];
	} else {
		account.isEnabled = [NSNumber numberWithBool:FALSE];
	}
	[self enableSaveIfValid];
}

- (void)loginRequiredUpdated:(UISwitch *)sender {
	NSLog(@"Login Required Updated");
	if (sender.on) {
		account.requiresLogin = [NSNumber numberWithBool:TRUE];
	} else {
		account.requiresLogin = [NSNumber numberWithBool:FALSE];
	}
	[self enableSaveIfValid];
}

- (void)accountUrlUpdated:(UITextField *)sender {
	NSLog(@"Account URL Updated");
	account.url = sender.text;
	[self enableSaveIfValid];
}

- (void)emailUpdated:(UITextField *)sender {
	NSLog(@"Email updated");
	account.username = sender.text;
	[self enableSaveIfValid];
}

- (void)enableSaveIfValid {
	NSLog(@"enableSaveIfValid: %@", account);
	BOOL valid = NO;
	if ([[account accountType] isEqualToString:@"gallery"]) {
#ifdef DEBUG 
		NSLog(@"Validating Gallery Account");
#endif
		valid = [WAGallery validate:account];
	} 
	if ([[account accountType] isEqualToString:@"facebook"]) {
#ifdef DEBUG 
		NSLog(@"Validating Facebook Account");
#endif
		valid = [WAFacebook validate:account];
	} 
	if ([[account accountType] isEqualToString:@"picasa"]) {
#ifdef DEBUG 
		NSLog(@"Validating Picasa Account");
#endif
		valid = [WAPicasa validate:account];
	} 
	if ([[account accountType] isEqualToString:@"generic"]) {
#ifdef DEBUG 
		NSLog(@"Validating Generic Account");
#endif
		valid = [WAGenericUrl validate:account];
	}
	NSLog(@"enableSaveIfValid: %@", account);

	[saveButton setEnabled:valid];
}
	
- (void)dealloc {
	[accountUrlElement release];
	[userNameElement release];
	[passWordElement release];
	[sections release];
	[cancelButton release];
	[saveButton release];
    [super dealloc];
}


@end
