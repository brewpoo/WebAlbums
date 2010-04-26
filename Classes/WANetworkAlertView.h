//
//  WANetworkAlertView.h
//  Adapted from wikiHow
//
//  Created by Keishi Hattori on 4/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WANetworkAlertView : UIAlertView {
	BOOL noConnectionAlert;
}

- (id)initWithError:(NSError *)error;
- (id)initNoReachability;

@end
