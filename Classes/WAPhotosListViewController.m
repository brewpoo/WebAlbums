//
//  WAPhotosListViewController.m
//  WebAlbums
//
//  Created by JJL on 7/15/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import "WAPhotosListViewController.h"
#import "WAPhotoDetailViewController.h"
#import "WAPhoto.h"
#import "AsyncImageView.h"
#import "ImageCache.h"


@implementation WAPhotosListViewController

@synthesize managedObjectContext;
@synthesize accountController;
@synthesize album;
@synthesize account;
@synthesize photos;
@synthesize photoDetailViewController;


//Will get this from User Defaults
#define IMAGE_SIZE 120.0

- (id)initWithAccountController:(WAAccountType*)thisController andAlbum:(WAAlbum*)thisAlbum {
	self = [super initWithStyle:UITableViewStylePlain];
	managedObjectContext = [thisAlbum.managedObjectContext retain];
	album = [thisAlbum retain];
	account = [album.account retain];
	account.delegate = self;
	accountController = [thisController retain];
	[accountController getPhotosForAlbum:album];
	return self;
}

- (void)updateDataSource {
	[managedObjectContext refreshObject:album mergeChanges:YES];
	NSArray *temp  = [album.photos allObjects];
	
	NSSortDescriptor *sortedBy;
	if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"photosNewestFirst"] boolValue] == YES) {
		sortedBy = [[[NSSortDescriptor alloc] initWithKey:@"someDate" ascending:NO] autorelease];
	} else {
		sortedBy = [[[NSSortDescriptor alloc] initWithKey:@"someDate" ascending:YES] autorelease];
	}
	if (photos) {
		[photos autorelease];
	}
	photos = [temp sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortedBy]];
		
	[photos retain];
	[self.tableView reloadData];
}
	
- (void)albumPhotosUpdated {
#ifdef DEBUG
	NSLog(@"Updated photo data");
#endif
	[self updateDataSource];
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[super viewDidLoad];
	self.tableView.rowHeight = IMAGE_SIZE;
	self.navigationItem.title = album.name;
	// Add toolbar with buttons to reload photo list and to add album to favorites
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

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	[[ImageCache sharedImageCache] removeAllImagesInMemory];
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
    return [photos count];
}


#define PHOTO_TAG 999
#define TITLE_TAG 10
#define SUBTITLE_TAG 11


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Photo";
    
	WAPhoto *photo = (WAPhoto*)[photos objectAtIndex:indexPath.row];
	
	UILabel *cellTitle, *cellSubtitle;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		cellTitle = [[[UILabel alloc] initWithFrame:CGRectMake(IMAGE_SIZE + 5.0, IMAGE_SIZE - 65.0, 160.0, 50.0)] autorelease];
		cellTitle.tag = TITLE_TAG;
		cellTitle.font = [UIFont systemFontOfSize:16.0];
		cellTitle.textAlignment = UITextAlignmentLeft;
		cellTitle.textColor = [UIColor blackColor];
		cellTitle.numberOfLines = 2;
		cellTitle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		//cellTitle.backgroundColor = [UIColor blueColor];
		
		cellSubtitle = [[[UILabel alloc] initWithFrame:CGRectMake(IMAGE_SIZE + 5.0, IMAGE_SIZE - 15.0, 160.0, 10.0)] autorelease];
		cellSubtitle.tag = SUBTITLE_TAG;
		cellSubtitle.font = [UIFont systemFontOfSize:12.0];
		cellSubtitle.textAlignment = UITextAlignmentLeft;
		cellSubtitle.textColor = [UIColor grayColor];
		cellSubtitle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		//cellSubtitle.backgroundColor = [UIColor redColor];
		
		[cell.contentView addSubview:cellTitle];
		[cell.contentView addSubview:cellSubtitle];
    } else {
		UIImageView *oldImage = (UIImageView*)[cell.contentView viewWithTag:PHOTO_TAG];
		[oldImage removeFromSuperview];	
		cellTitle = (UILabel *)[cell.contentView viewWithTag:TITLE_TAG];
		cellSubtitle = (UILabel *)[cell.contentView viewWithTag:SUBTITLE_TAG];
	}
	
	AsyncImageView* asyncImage = [[[AsyncImageView alloc]
								   initWithFrame:CGRectMake(0.0, 0.0, IMAGE_SIZE, IMAGE_SIZE)] autorelease];
	asyncImage.tag = PHOTO_TAG;
	asyncImage.contentMode = UIViewContentModeScaleAspectFit;	
	NSURL *url = [NSURL URLWithString:photo.thumbnailPath];
	if (url==nil) {
		return cell;
	}
	[asyncImage loadImageFromURL:url];
	
	// Set up the cell...
	cellTitle.text = photo.title;
	cellSubtitle.text = [photo dateTaken];
	[cell.contentView addSubview:asyncImage];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"markNewPhotos"]) {
		if ([photo.wasViewed boolValue]==NO) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
		
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	WAPhoto *photo = [photos objectAtIndex:indexPath.row];
	photoDetailViewController = [[[WAPhotoDetailViewController alloc] initWithAccountController:accountController 
										andAlbum:album atPhoto:photo] retain];
	photoDetailViewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:photoDetailViewController animated:YES];
	
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
	[album release];
	[account release];
	[photos release];
	[photoDetailViewController release];
    [super dealloc];
}


@end

