//
//  WAPhotoDetailViewController.h
//  WebAlbums
//
//  Created by JJL on 7/25/09.
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


#import <UIKit/UIKit.h>
#import "WAAccountType.h"
#import "WAAccount.h"
#import "WAAlbum.h"
#import "WAPhoto.h"
#import "ZoomScrollView.h"

typedef enum {
	ScrollViewModeNotInitialized,           // view has just been loaded
	ScrollViewModePaging,                   // fully zoomed out, swiping enabled
	ScrollViewModeZooming,                  // zoomed in, panning enabled
} ScrollViewMode;


@interface WAPhotoDetailViewController : UIViewController <WAAccountDelegate, UIScrollViewDelegate> {
	NSManagedObjectContext *managedObjectContext;
	WAAlbum *album;
	WAAccount *account;
	WAPhoto *currentPhoto;
	NSArray *photos;
	WAAccountType *accountController;
	UIToolbar *toolbar;
	NSMutableArray *photoViewControllers;
	ZoomScrollView *scrollView;
	NSUInteger currentPage;
	ScrollViewMode scrollViewMode;
	NSTimer *timer;

}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) WAAlbum *album;
@property (nonatomic, retain) WAAccount *account;
@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, retain) WAPhoto *currentPhoto;
@property (nonatomic, retain) WAAccountType *accountController;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) NSMutableArray *photoViewControllers;
@property (nonatomic, retain) NSTimer *timer;

- (id)initWithAccountController:(WAAccountType*)thisController andAlbum:(WAAlbum*)thisAlbum atPhoto:(WAPhoto*)currentPhoto;
- (void)currentPhotoUpdated;
- (void)setPagingMode;
- (void)setZoomingMode;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;


@end
