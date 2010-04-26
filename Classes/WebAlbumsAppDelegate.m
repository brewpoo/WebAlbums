//
//  WebAlbumsAppDelegate.m
//  WebAlbums
//
//  Created by JJL on 6/20/09.
//  Copyright NetGuyzApps 2009. All rights reserved.
//

#import "WebAlbumsAppDelegate.h"
#import "WAAccountsViewController.h"
#import "WAFavoriteAlbumsViewController.h"
#import "WAFavoritePhotosViewController.h"
#import "WASettingsViewController.h"
#import "WATabBarController.h"

#import "WANetworkAlertView.h"
#import "Reachability.h"

#import "Constants.h"
#import "FlurryAPI.h"

@implementation WebAlbumsAppDelegate

@synthesize window;
@synthesize tabBarController;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
#ifdef DEBUG
	NSLog(@"Application Starting Up");
#endif
	
	tabBarController = [[WATabBarController alloc] initWithNibName:nil bundle:nil];
	
	// Bring in managed object context
	NSManagedObjectContext *context = [self managedObjectContext];
    if (!context) {
        // Handle the error.
    }
	
	// Check for first run and set defaults
	id temp;
	temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"photosNewestFirst"];
	if (temp==nil) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"photosNewestFirst"];
	}
	temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"markNewPhotos"];
	if (temp==nil) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"markNewPhotos"];
	}
	
	//CGRect myBounds = CGRectMake(0, 0, 320, 480);
	// Init Account nav and first view controller
	WAAccountsViewController *accountsViewController = [[[WAAccountsViewController alloc] 
														 initWithNibName:nil bundle:nil] autorelease]; 
	accountsViewController.tabBarItem.title = @"Accounts";
	accountsViewController.tabBarItem.image = [UIImage imageNamed:@"Category.png"];
	accountsViewController.navigationItem.title = @"Accounts";
	accountsViewController.managedObjectContext = managedObjectContext;

	accountsViewController.view.autoresizesSubviews = NO;
	UINavigationController *accountNavController = [[UINavigationController alloc] initWithRootViewController:accountsViewController]; 
	
	// Init Favorite Album nav and first view controller
	WAFavoriteAlbumsViewController *albumsViewController = [[[WAFavoriteAlbumsViewController alloc] 
															initWithNibName:nil bundle:nil] autorelease]; 
	albumsViewController.tabBarItem.title = @"Albums";
	albumsViewController.tabBarItem.image = [UIImage imageNamed:@"Star.png"];
	albumsViewController.navigationItem.title = @"Favorite Albums";
	UINavigationController *albumNavController = [[UINavigationController alloc] initWithRootViewController:albumsViewController];
	
	// Init Favorite Photo nav and first view controller
	WAFavoritePhotosViewController *photosViewController = [[[WAFavoritePhotosViewController alloc] 
															initWithNibName:nil bundle:nil] autorelease]; 
	photosViewController.tabBarItem.title = @"Photos";
	photosViewController.tabBarItem.image = [UIImage imageNamed:@"Heart.png"];
	photosViewController.navigationItem.title = @"Favorite Photos";
	UINavigationController *photoNavController = [[UINavigationController alloc] initWithRootViewController:photosViewController];
	
	// Init Settings view controller
	WASettingsViewController *settingsViewController = [[[WASettingsViewController alloc]
														 initWithStyle:UITableViewStyleGrouped] autorelease];
	settingsViewController.tabBarItem.title = @"Settings";
	settingsViewController.tabBarItem.image = [UIImage imageNamed:@"Settings.png"];
	settingsViewController.navigationItem.title = @"Settings";
	settingsViewController.managedObjectContext = managedObjectContext;
	UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
	
    // Pass the managed object context to the view controllers.
    //accountsViewController.managedObjectContext = context;
	
	tabBarController.viewControllers = [NSArray arrayWithObjects:accountNavController, albumNavController, photoNavController, settingsNavController, nil];

#ifdef DEBUG
	NSLog(@"Adding Tab Bar Controller and making visible");
#endif
	
#ifndef DEBUG
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	[FlurryAPI startSession:FLURRY_API_KEY];
#endif

	[window addSubview:tabBarController.view];
	[window makeKeyAndVisible];
	
	// Add Network Reachability Handler
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:@"kNetworkReachabilityChangedNotification" object:nil];
	[self updateStatus];

}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle error
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
        } 
    }
}

void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}

#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"WebAlbums.sqlite"]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle error
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark -
#pragma mark Reachability 

- (void)updateStatus {
	// Query the SystemConfiguration framework for the state of the device's network connections.
	NetworkStatus status = [[Reachability sharedReachability] internetConnectionStatus];
	if (status==NotReachable) {
		WANetworkAlertView *alertView = [[WANetworkAlertView alloc] initNoReachability];
		[alertView show];
		[alertView release];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[tabBarController release];
	[window release];
	[super dealloc];
}


@end

