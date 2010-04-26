//
//  WAAlbumsViewController.h
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


#import <UIKit/UIKit.h>
#import "WAAccountType.h"
#import "WAAccount.h"

@interface WAAlbumsViewController : UITableViewController <WAAccountDelegate> {
	NSManagedObjectContext *managedObjectContext;
	WAAccountType *accountController;
	WAAccount *account;
	NSArray *albums;
	UITableViewController *photosViewController;
	
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) WAAccountType *accountController;
@property (nonatomic, retain) WAAccount *account;
@property (nonatomic, retain) NSArray *albums;
@property (nonatomic, retain) UITableViewController *photosViewController;

- (id)initWithAccount:(WAAccount*)thisAccount;
- (void)accountAlbumsUpdated;

@end
