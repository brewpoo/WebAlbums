//
//  WATableFormSection.h
//  WebAlbums
//
//  Created by JJL on 6/24/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WATableFormSection : NSObject {
	NSMutableArray	*elements;
	NSString		*sectionHeader;
	BOOL			isVisible;
	
}

@property (nonatomic,retain) NSMutableArray *elements;
@property (nonatomic,retain) NSString *sectionHeader;
@property (nonatomic,assign) BOOL isVisible;

@end
