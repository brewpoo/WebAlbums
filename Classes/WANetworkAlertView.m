//
//  WANetworkAlertView.m
//  Adapted from wikiHow
//
//  Created by Keishi Hattori on 4/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
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


#import "WANetworkAlertView.h"
#import "WebAlbumsAppDelegate.h"


@implementation WANetworkAlertView


- (id)initWithError:(NSError *)error {
    if ([error code] == -1009) {
		[self initWithTitle:@"You are not connected to the Internet." message:@"To view photos you must be connected to the Internet." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		noConnectionAlert = YES;
	} else {
		[self initWithTitle:@"Network Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		noConnectionAlert = NO;
	}
    return self;
}

- (id)initNoReachability {
	[self initWithTitle:@"You are not connected to the Internet." message:@"To view albums and images you must be connected to the Internet." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	noConnectionAlert = YES;
	return self;
}

- (void)_selectTabForButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		((WebAlbumsAppDelegate *)[UIApplication sharedApplication].delegate).tabBarController.selectedIndex = 0;
	}
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
	if (noConnectionAlert) {
		[self _selectTabForButtonIndex:buttonIndex];
	}
	[super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}


@end
