//
//  AsyncImageView.h
//  WebAlbums
//
//  Created by JJL on 7/22/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AsyncImageView : UIImageView {
	//could instead be a subclass of UIImageView instead of UIView, depending on what other features you want to 
	// to build into this class?
	
	NSURLConnection* connection; //keep a reference to the connection so we can cancel download in dealloc
	NSMutableData* data; //keep reference to the data so we can collect it as it downloads
	//but where is the UIImage reference? We keep it in self.subviews - no need to re-code what we have in the parent class
	UIActivityIndicatorView *activity;
	NSURL *thisUrl;
	
}

- (void)loadImageFromURL:(NSURL*)url;

@end
