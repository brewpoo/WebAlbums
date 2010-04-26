//
//  WAAddFacebookViewController.m
//  WebAlbums
//
//  Created by JJL on 6/22/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import "WAAddFacebookViewController.h"
#import "WATableFormControl.h"
#import "WATableFormSection.h"

@implementation WAAddFacebookViewController

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
	self.navigationItem.title = @"Facebook";

	if ([account.isNew integerValue]==1) {
		account.settings = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"taggedPhotos"];
	}
	
	// Add switch for Photos of Me
	UISwitch *taggedPhotos = [[UISwitch alloc] initWithFrame:CGRectMake(200, 10, 20.0, 20.0)];
	taggedPhotos.on = YES;
	if([account.isNew integerValue]!=1) { taggedPhotos.on=[[account.settings valueForKey:@"taggedPhotos"] boolValue]; }
	[taggedPhotos addTarget:self action:@selector(taggedPhotosUpdated:) forControlEvents:(UIControlEventValueChanged | UIControlEventTouchDragInside)];
	WATableFormControl *taggedPhotosElement = [[WATableFormControl alloc] init];
	[taggedPhotosElement addControl:taggedPhotos];
	taggedPhotosElement.label = @"Include Photos of Me";
	
	WATableFormSection *section = [[WATableFormSection alloc] init];
	section.sectionHeader = @"Facebook settingss";
	[section.elements addObject:taggedPhotosElement];
	[sections addObject:section];
	[taggedPhotos release];
	[taggedPhotosElement release];
	[section release];
	
}


- (void)taggedPhotosUpdated:(UISwitch *)sender {
	NSLog(@"Tagged Photos Update");
	[account.settings setValue:[NSNumber numberWithBool:sender.on] forKey:@"taggedPhotos"];
	[self enableSaveIfValid];
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

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
