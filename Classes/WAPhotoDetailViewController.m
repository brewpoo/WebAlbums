//
//  WAPhotoDetailViewController.m
//  WebAlbums
//
//  Created by JJL on 7/25/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import "WAPhotoDetailViewController.h"
#import "WAAccountType.h"
#import "WAAlbum.h"
#import "WAAccount.h"
#import "WAPhoto.h"
#import "AsyncImageView.h"

#define kHideDelay 5.0

@implementation WAPhotoDetailViewController

@synthesize managedObjectContext;
@synthesize accountController;
@synthesize account;
@synthesize album;
@synthesize currentPhoto;
@synthesize photos;
@synthesize toolbar;
@synthesize photoViewControllers;
@synthesize timer;

- (id)initWithAccountController:(WAAccountType*)thisController andAlbum:(WAAlbum*)thisAlbum atPhoto:(WAPhoto*)thisPhoto {
	self = [super initWithNibName:nil bundle:nil];
	managedObjectContext = [thisAlbum.managedObjectContext retain];
	album = [thisAlbum retain];
	account = [album.account retain];
	account.delegate = self;
	accountController = [thisController retain];
	currentPhoto = thisPhoto;
	
	[managedObjectContext refreshObject:account mergeChanges:YES];
	
	NSSortDescriptor *sortedBy;
	if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"photosNewestFirst"] boolValue] == YES) {
		sortedBy = [[[NSSortDescriptor alloc] initWithKey:@"someDate" ascending:NO] autorelease];
	} else {
		sortedBy = [[[NSSortDescriptor alloc] initWithKey:@"someDate" ascending:YES] autorelease];
	}
	NSArray *temp  = [album.photos allObjects];
	if (photos) {
		[photos autorelease];
	}
	photos = [temp sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortedBy]];
	[photos retain];
	
	currentPage = [photos indexOfObject:currentPhoto];
	return self;
}


/*
- (void)loadScrollViewWithIndex:(int)index {
    if (index < 0) return;
    if (index >= (int)album.cachedCount) return;
	
    // replace the placeholder if necessary
    WAPhotoViewController *controller = [photoViewControllers objectAtIndex:index];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[WAPhotoViewController alloc] initWithPhotoIndex:index];
        [photoViewControllers replaceObjectAtIndex:index withObject:controller];
        [controller release];
    }
	
    // add the controller's view to the scroll view
    if (nil == controller.view.superview) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * index;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
    }
}
*/


- (void)currentPhotoUpdated {
}


- (void)loadView {
	//CGRect frame = [UIScreen mainScreen].applicationFrame;
//	CGRect frame = CGRectMake(0.0, -20.0, 320.0, 480.0);
	CGRect frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
	scrollView = [[ZoomScrollView alloc] initWithFrame:frame];
	scrollView.delegate = self;
	scrollView.maximumZoomScale = 4.0f;
	scrollView.minimumZoomScale = 1.0f;
	scrollView.zoomInOnDoubleTap = scrollView.zoomOutOnDoubleTap = YES;
	scrollView.alwaysBounceVertical = NO;
	scrollView.autoresizesSubviews = NO;
	//[scrollView setContentSize:CGSizeMake(480,320*[photos count])];
	//UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red.png"]];
	//UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green.png"]];
	//UIImageView *imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yellow-blue.png"]];

	// in a real app, you most likely want to have an array of view controllers, not views;
	// also should be instantiating those views and view controllers lazily
	
	self.view = scrollView;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];

	scrollViewMode = ScrollViewModeNotInitialized;
	[self setPagingMode];
	
	// view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    photoViewControllers = [[NSMutableArray alloc] initWithCapacity:(int)album.cachedCount];
	for (int i=0;i<(int)[album.cachedCount intValue];i++) {
		[photoViewControllers addObject:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo.jpg"]]];
	}
	
	/*
	
	 AsyncImageView* asyncImage = [[[AsyncImageView alloc]
	 initWithFrame:CGRectMake(0.0, 0.0, IMAGE_SIZE, IMAGE_SIZE)] autorelease];
	 asyncImage.tag = PHOTO_TAG;
	 asyncImage.contentMode = UIViewContentModeScaleAspectFit;	
	 NSURL *url = [NSURL URLWithString:photo.thumbnailPath];
	 if (url==nil) {
	 return cell;
	 }
	 [asyncImage loadImageFromURL:url];
	 */
	
	// Start loading the current image and the next
	WAPhoto *photo = [photos objectAtIndex:currentPage];
	AsyncImageView* asyncImage = [[[AsyncImageView alloc]
								   initWithFrame:CGRectMake(0.0, 0.0, 300.0, 460.0)] retain];
	asyncImage.contentMode = UIViewContentModeScaleAspectFit;
	NSURL *url = [NSURL URLWithString:photo.imagePath];
	if (url!=nil) {
		[asyncImage loadImageFromURL:url];
		[photoViewControllers replaceObjectAtIndex:currentPage withObject:asyncImage];
	}
	
	// Next page
	NSInteger nextIndex;
	if (currentPage == [photos count]-1) {
		nextIndex = -1;
	} else {
		nextIndex = 1;
	}
	
	WAPhoto *nextPhoto = [photos objectAtIndex:currentPage+nextIndex];
	AsyncImageView *asyncImage2 = 
	asyncImage = [[[AsyncImageView alloc]
								  initWithFrame:CGRectMake(0.0, 0.0, 300.0, 460.0)] autorelease];
	
	asyncImage2.contentMode = UIViewContentModeScaleAspectFit;
	url = [NSURL URLWithString:nextPhoto.imagePath];
	if (url!=nil) {
		[asyncImage2 loadImageFromURL:url];
		[photoViewControllers replaceObjectAtIndex:currentPage+nextIndex withObject:asyncImage2];
	}
	[photoViewControllers retain];
	// Change background color
	self.view.backgroundColor = [UIColor blackColor];
	
	
	//Create a button
	UIBarButtonItem *actionButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self
									 action:@selector(actionButtonClicked:)];
	
	
	[self setToolbarItems:[NSArray arrayWithObjects:actionButton,nil]];
	self.navigationController.toolbarHidden = NO;
	
	self.title = [NSString stringWithFormat:@"%d of %d", currentPage+1, [photos count]];

	NSLog(@"Current Page: %d", currentPage);
	
	//Add the toolbar as a subview to the navigation controller.
	[self setPagingMode];
	
	// Start the timer to hide the nav bars
	timer = [NSTimer scheduledTimerWithTimeInterval:kHideDelay target:self
								   selector:@selector(hideNavigationStuff:)
								   userInfo:nil
									repeats:NO];
	[timer retain];

	// Preload the current and next images

}

- (void)viewDidUnload {
	[photoViewControllers release]; // need to release all page views here; our array is created in loadView, so just releasing it
	photoViewControllers = nil;
}

-(void)viewWillAppear:(BOOL)animated {
	NSLog(@"View will appear");
	[super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	//self.navigationController.view.frame = CGRectMake(0.0, -20.0, 320.0, 500.0);
	//self.navigationController.view.subview = NO;
	self.view.frame = self.navigationController.view.frame;
	self.wantsFullScreenLayout = YES;
	self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	self.navigationController.toolbarHidden = NO;
	//self.navigationController.navigationBar.translucent = YES;
	//self.navigationController.view.autoresizesSubviews = NO;
	//self.wantsFullScreenLayout = YES;
	//[self.view setContentSize:[[UIScreen mainScreen] bounds].size];
	//[self.view setContentOffset:CGPointMake(0,0) animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated { 
	if (timer) [timer invalidate];
	NSLog(@"View will disappear");
	[super viewWillDisappear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
	self.navigationController.toolbar.barStyle = UIBarStyleDefault;
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	self.navigationController.toolbarHidden = YES;
	[self.navigationController.navigationBar setAlpha:1.0];
	//self.navigationController.navigationBar.translucent = NO;
	//self.navigationController.view.autoresizesSubviews = YES;
	[self.navigationController setNavigationBarHidden:NO];
}




#pragma mark Touch/Timer Controls

- (void)hideNavigationStuff:(id)sender {
	[toolbar setAlpha:0.0];	
	[self.navigationController.navigationBar setAlpha:0.0];
	[self.navigationController.toolbar setAlpha:0.0];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:20.0];
	[UIView commitAnimations];
}

- (void)showNavigationStuff:(id)sender {
	[toolbar setAlpha:1.0];
	[self.navigationController.navigationBar setAlpha:1.0];
	[self.navigationController.toolbar setAlpha:1.0];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:20.0];
	[UIView	commitAnimations];
	timer = [NSTimer scheduledTimerWithTimeInterval:kHideDelay target:self
								   selector:@selector(hideNavigationStuff:)
								   userInfo:nil
									repeats:NO];
}

- (void)toggleNavigationStuff:(id)sender {
	BOOL navHidden = self.navigationController.navigationBarHidden;
	if (navHidden==YES) {
		[self showNavigationStuff:self];
	} else {
		[self hideNavigationStuff:self];
	}
}
	

#pragma mark Scrolling Madness

- (CGSize)pageSize {
	CGSize pageSize = scrollView.frame.size;
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
		return CGSizeMake(pageSize.height, pageSize.width);
	else
		return pageSize;
}

- (void)setPagingMode {
	NSLog(@"setPagingMode");
	// reposition pages side by side, add them back to the view
	CGSize pageSize = [self pageSize];
	NSUInteger page = 0;
	for (UIView *view in photoViewControllers) {
		if (!view.superview)
			[scrollView addSubview:view];
		view.frame = CGRectMake(pageSize.width * page++, 0, pageSize.width, pageSize.height);
	}
	
	scrollView.pagingEnabled = YES;
	scrollView.showsVerticalScrollIndicator = scrollView.showsHorizontalScrollIndicator = NO;
	
	scrollView.contentSize = CGSizeMake(pageSize.width * [photoViewControllers count], pageSize.height);
	scrollView.contentOffset = CGPointMake(pageSize.width * currentPage, 0);
	
	scrollViewMode = ScrollViewModePaging;
}

- (void)setZoomingMode {
	NSLog(@"setZoomingMode");
	scrollViewMode = ScrollViewModeZooming; // has to be set early, or else currentPage will be mistakenly reset by scrollViewDidScroll
	
	CGSize pageSize = [self pageSize];
	
	// hide all pages besides the current one
	NSUInteger page = 0;
	for (UIView *view in photoViewControllers)
		if (currentPage != page++)
			[view removeFromSuperview];
	
	// move the current page to (0, 0), as if no other pages ever existed
	[[photoViewControllers objectAtIndex:currentPage] setFrame:CGRectMake(0, 0, pageSize.width, pageSize.height)];
	
	scrollView.pagingEnabled = NO;
	scrollView.showsVerticalScrollIndicator = scrollView.showsHorizontalScrollIndicator = YES;
	scrollView.contentSize = pageSize;
	scrollView.contentOffset = CGPointZero;
	scrollView.bouncesZoom = YES;
}

- (void)setCurrentPage:(NSUInteger)page {
	if (page == currentPage)
		return;
	currentPage = page;
	NSLog(@"Page Changed");
	self.title = [NSString stringWithFormat:@"%d of %d", page+1, [photos count]];
	// in a real app, this would be a good place to instantiate more view controllers -- see SDK examples
/*
	AsyncImageView* asyncImage = [[[AsyncImageView alloc]
								   initWithFrame:CGRectMake(0.0, 0.0, IMAGE_SIZE, IMAGE_SIZE)] autorelease];
	asyncImage.tag = PHOTO_TAG;
	asyncImage.contentMode = UIViewContentModeScaleAspectFit;	
	NSURL *url = [NSURL URLWithString:photo.thumbnailPath];
	if (url==nil) {
		return cell;
	}
	[asyncImage loadImageFromURL:url];
 */
}


# pragma mark Scroll and Zoom Handling

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
	if (scrollViewMode == ScrollViewModePaging)
		[self setCurrentPage:(roundf(scrollView.contentOffset.x / [self pageSize].width))];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
	if (scrollViewMode != ScrollViewModeZooming)
		[self setZoomingMode];
	return [photoViewControllers objectAtIndex:currentPage];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)aScrollView withView:(UIView *)view atScale:(float)scale {
	if (scrollView.zoomScale == scrollView.minimumZoomScale)
		[self setPagingMode];
}
\

# pragma mark Unhide navigation bars after touch events

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self showNavigationStuff:self];
}



# pragma mark Rotation Handling

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	NSLog(@"Did Rotate");
	if (scrollViewMode == ScrollViewModePaging) {
		scrollViewMode = ScrollViewModeNotInitialized;
		[self setPagingMode];
	} else {
		[self setZoomingMode];
	}
}


- (void)dealloc {
    [super dealloc];
	[timer release];
	[photos release];
	[album release];
	[account release];
	[accountController release];
	[toolbar release];
	[photoViewControllers release];
}

@end
