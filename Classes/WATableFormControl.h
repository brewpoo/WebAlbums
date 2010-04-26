//
//  WATableFormControl.h
//  WebAlbums
//
//  Created by JJL on 6/24/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WATableFormControl : NSObject {
	NSObject *control;
	NSString *label;

}

@property (nonatomic,retain) NSObject *control;
@property (nonatomic, retain) NSString *label;

- (void)addControl:(NSObject *)newControl;

@end
