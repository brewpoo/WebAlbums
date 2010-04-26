//
//  WAPhotosListViewController.h
//  WebAlbums
//
//  Created by JJL on 7/15/09.
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
#import "WAAlbum.h"
#import "WAAccount.h"
#import "WAAccountType.h"


@interface WAPhotosListViewController : UITableViewController <WAAccountDelegate> {
	NSManagedObjectContext *managedObjectContext;
	WAAlbum *album;
	WAAccount *account;
	NSArray *photos;
	UIViewController *photoDetailViewController;
	WAAccountType *accountController;
	
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) WAAlbum *album;
@property (nonatomic, retain) WAAccount *account;
@property (nonatomic, retain) NSArray *photos;
@property (nonatomic, retain) UIViewController *photoDetailViewController;
@property (nonatomic, retain) WAAccountType *accountController;

- (id)initWithAccountController:(WAAccountType*)thisController andAlbum:(WAAlbum*)thisAlbum;
- (void)albumPhotosUpdated;

@end
