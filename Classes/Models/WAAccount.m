// 
//  WAAccount.m
//  WebAlbums
//
//  Created by JJL on 7/5/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import "WAAccount.h"
#import "WAAlbum.h"
#import "WAPhoto.h"
#import "SFHFKeychainUtils.h"
#import "GDataPhotos.h"
#import "ZWGalleryAlbum.h"

@implementation WAAccount 

@dynamic url;
@dynamic accountType;
@dynamic name;
@dynamic username;
@dynamic isReadOnly;
@dynamic requiresLogin;
@dynamic isEnabled;
@dynamic albums;
@dynamic settings;
@synthesize password;
@synthesize formPassword;
@synthesize isNew;
@synthesize delegate;

- (BOOL) validate {
	return true;
}

- (NSString *)serviceName {
	if (self.url!=nil) {
		return self.url;
	} else {
		return self.accountType;
	}
}

- (NSString *)fetchPassword {
	if ([self.password length]>0) {
		return self.password;
	}
	NSLog(@"Username: %@, Service Name:%@",self.username, [self serviceName]);
	NSError *error = nil;
	NSString *temp = [SFHFKeychainUtils getPasswordForUsername:self.username andServiceName:[self serviceName] error:&error];
	if (temp==nil) {
#ifdef DEBUG
		NSLog(@"Password retrieve error, %@",error);
#endif
		return false;
	}
	NSLog(@"Got Password");
	self.password = temp;
	return temp;
}

-(void)savePassword:(NSString *)newPassword {
	NSLog(@"Saving password: %@ as service %@", self.formPassword, [self serviceName]);
	NSError *error = nil;
	[SFHFKeychainUtils storeUsername:self.username andPassword:self.formPassword forServiceName:[self serviceName] updateExisting:YES error:&error];
#ifdef DEBUG
	NSLog(@"Error: %@", error);
#endif
}

/*
 * Facebook integration
 */

-(void)addFacebookAlbums:(NSArray*)newAlbums {
	// Identify new albums and create new ones, update the photo count as well
	// There are no nested albums on Facebook so this should be easy
	// Need to fetch and assign thumbnail too
	
	if (newAlbums == nil) {
		return;
	}
	
	NSManagedObjectContext *moc = self.managedObjectContext;
	NSError *error = nil;
	
	BOOL getTaggedPhotos = [[[self settings] valueForKey:@"taggedPhotos"] boolValue];
	getTaggedPhotos = YES;
	
	// Turn of undo management
	[[moc undoManager] disableUndoRegistration];
	
#ifdef DEBUG
	NSLog(@"In addFacebookAlbums: %@",newAlbums);
#endif
	// Enumerate through new albums to add/update
	for (id newAlbum in newAlbums) {
		// Will never contain the special album aid==0
		BOOL found = NO;
		for (WAAlbum *album in self.albums) {
			if ([album.uniqueId longLongValue] == [[newAlbum valueForKey:@"aid"] longLongValue]) {
				// Existing item found
				found = YES;
#ifdef DEBUG
				NSLog(@"Found existing album %@",album.uniqueId);
#endif
				//Update attributes
				album.name = [newAlbum valueForKey:@"name"];
				album.cachedCount = [NSNumber numberWithInt:[[newAlbum valueForKey:@"size"] intValue]];
			} 
		}
		if (found == NO) {
			// newAlbum doesn't exist, create it
#ifdef DEBUG
			NSLog(@"New Album %@ found", [newAlbum valueForKey:@"name"]);
#endif
			WAAlbum *buildAlbum = (WAAlbum *)[NSEntityDescription 
											  insertNewObjectForEntityForName:@"Album" 
											  inManagedObjectContext:moc];
			buildAlbum.name = [newAlbum valueForKey:@"name"];
			buildAlbum.uniqueId = [NSNumber numberWithLongLong:[[newAlbum valueForKey:@"aid"] longLongValue]];
			buildAlbum.cachedCount = [NSNumber numberWithInt:[[newAlbum valueForKey:@"size"] intValue]];
			[self addAlbumsObject:buildAlbum];
		}
	}
	[moc save:&error];
	if (error) {
		NSLog(@"Error: %@", error);
	}
	
	BOOL taggedAlbumFound = NO;

	// Now need to search the other way around to prune removed albums
	NSMutableSet *tbr = [NSMutableSet setWithCapacity:1];
	for (WAAlbum *album in self.albums) {
		BOOL found = NO;
		// Check for and add/remove Tagged Photos album
		if ([album.uniqueId intValue] == 1) {
			taggedAlbumFound = YES;
			if (getTaggedPhotos == YES) {
			} else {
				[tbr addObject:album];
			}
		} else {
			for (id newAlbum in newAlbums) {
				if ([album.uniqueId longLongValue] == [[newAlbum valueForKey:@"aid"] longLongValue]) {
					found = YES;
				}
			}
			if (found == NO) {
				// Album no longer exists, prune it
#ifdef DEBUG
				NSLog(@"Found removed album, pruning %@", album);
#endif
				[tbr addObject:album];
			}
		}
	}
	
	
	
	if ([tbr count]>0) {
		NSLog(@"%d albums to be removed", [tbr count]);
		[self removeAlbums:tbr];
	}
	
	if (taggedAlbumFound == NO & getTaggedPhotos == YES) {
		// Add the tagged photo album
#ifdef DEBUG
		NSLog(@"Adding Tagged Photo Album");
#endif
		WAAlbum *buildAlbum = (WAAlbum *)[NSEntityDescription 
										  insertNewObjectForEntityForName:@"Album" 
										  inManagedObjectContext:moc];
		buildAlbum.name = @"Photos of Me";
		buildAlbum.uniqueId = [NSNumber numberWithInt:1];;
		[self addAlbumsObject:buildAlbum];
	}
	
	[moc save:&error];
	if (error) {
		NSLog(@"Error: %@", error);
	}
	
	[[moc undoManager] enableUndoRegistration];
			
	// Notify delegate
	if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(accountAlbumsUpdated)]) {
		[delegate accountAlbumsUpdated];
	}    
}

/* Example
 aid = 6832328485787048043;
 caption = "How big is Jackson? So big";
 created = 1238885090;
 link = "http://www.facebook.com/photo.php?pid=30099257&id=1590775439";
 modified = 1238885090;
 owner = 1590775439;
 pid = 6832328485815142201;
 src = "http://photos-b.ak.fbcdn.net/photos-ak-snc1/v2748/221/74/1590775439/s1590775439_30099257_4872380.jpg";
 "src_big" = "http://photos-b.ak.fbcdn.net/photos-ak-snc1/v2748/221/74/1590775439/n1590775439_30099257_4872380.jpg";
 "src_small" = "http://photos-b.ak.fbcdn.net/photos-ak-snc1/v2748/221/74/1590775439/t1590775439_30099257_4872380.jpg";
 }

 */

- (void)addFacebookPhotos:(NSArray*)newPhotos {
	// All newPhotos should belong to one album

	if (newPhotos == nil) {
		return;
	}
	
	NSManagedObjectContext *moc = self.managedObjectContext;
	NSError *error = nil;
	WAAlbum *destAlbum;
	
	// Turn of undo management
	[[moc undoManager] disableUndoRegistration];
	
	//Determine which album these photos are for	
	NSEntityDescription *entityDescription = [NSEntityDescription 
											  entityForName:@"Album" inManagedObjectContext:moc]; 
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease]; 
	[request setEntity:entityDescription]; 
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueId=%@",[[newPhotos objectAtIndex:0] valueForKey:@"aid"]];
	[request setPredicate:predicate];

	NSArray *result = [moc executeFetchRequest:request error:&error];
	if ([result count]>0) {
		destAlbum = [result objectAtIndex:0];
		NSLog(@"Found Album for photos: %@", destAlbum);
	} else {
		NSLog(@"Must be the special album");
		predicate = [NSPredicate predicateWithFormat:@"uniqueId=1"];
		[request setPredicate:predicate];
		destAlbum = [[moc executeFetchRequest:request error:&error] objectAtIndex:0];
		destAlbum.cachedCount = [NSNumber numberWithInt:[newPhotos count]];
	}
#ifdef DEBUG
	NSLog(@"In addFacebookPhotos: %@",newPhotos);
#endif
	// Enumerate through new photos to add/update
	for (id newPhoto in newPhotos) {
		BOOL found = NO;
		for (WAPhoto *photo in destAlbum.photos) {
			if ([photo.uniqueId longLongValue] == [[newPhoto valueForKey:@"pid"] longLongValue]) {
				// Existing item found
				found = YES;
				NSLog(@"Found existing photo %@",photo.uniqueId);
				//Update attributes
				photo.thumbnailPath = [NSString stringWithFormat:@"%@",[newPhoto valueForKey:@"src"]];
				photo.imagePath = [NSString stringWithFormat:@"%@",[newPhoto valueForKey:@"src_big"]];
				photo.title = [NSString stringWithFormat:@"%@",[newPhoto valueForKey:@"caption"]];
				photo.someDate = [NSNumber numberWithLongLong:[[newPhoto valueForKey:@"created"] longLongValue]];
				if ([photo.title isEqualToString:@"<null>"]) {
					photo.title=@"";
				}
			} 
		}
		if (found == NO) {
			// newPhoto doesn't exist, create it
#ifdef DEBUG
			NSLog(@"New photo %@ found", [newPhoto valueForKey:@"pid"]);
#endif
			WAPhoto *buildPhoto = (WAPhoto *)[NSEntityDescription 
											  insertNewObjectForEntityForName:@"Photo" 
											  inManagedObjectContext:moc];
			buildPhoto.uniqueId = [NSNumber numberWithLongLong:[[newPhoto valueForKey:@"pid"] longLongValue]];
			buildPhoto.title = [NSString stringWithFormat:@"%@",[newPhoto valueForKey:@"caption"]];
			buildPhoto.someDate = [NSNumber numberWithLongLong:[[newPhoto valueForKey:@"created"] longLongValue]];
			if ([buildPhoto.title isEqualToString:@"<null>"]) {
				buildPhoto.title = @"";
			}
			buildPhoto.wasViewed = [NSNumber numberWithBool:NO];
			buildPhoto.thumbnailPath = [newPhoto valueForKey:@"src"];
			buildPhoto.imagePath = [newPhoto valueForKey:@"src_big"];
			NSLog(@"New photo for CoreData: %@", buildPhoto);
			[destAlbum addPhotosObject:buildPhoto];
		}
	}
	[moc save:&error];
	if (error) {
		NSLog(@"Save error: %@",error);
	}
	
	// Now need to search the other way around to make prune removed photos
	NSMutableSet *tbr = [NSMutableSet setWithCapacity:1];
	for (WAPhoto *photo in destAlbum.photos) {
		BOOL found = NO;
		for (id newPhoto in newPhotos) {
			if ([photo.uniqueId longLongValue] == [[newPhoto valueForKey:@"pid"] longLongValue]) {
				found = YES;
				// Leave it be
			}
		}
		if (found == NO) {
			// Photo no longer exists, prune it
			NSLog(@"Found removed photo, pruning %@", photo);
			[tbr addObject:photo];
		}
	}
	
	[destAlbum removePhotos:tbr];
	[moc save:&error];
	if (error) {
		NSLog(@"Save Error: %@", error);
	}
			
	[[moc undoManager] enableUndoRegistration];
	
	// Notify delegate
	if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(albumPhotosUpdated)]) {
		NSLog(@"Delegating");
		[self.delegate albumPhotosUpdated];
	}  
	
}

#pragma mark Picasa Integration

-(void)addPicasaAlbums:(GDataFeedPhotoUser*)feed {
	if ([feed entries] == nil) {
		return;
	}
	
	NSManagedObjectContext *moc = self.managedObjectContext;
	NSError *error = nil;

	// Turn of undo management
	[[moc undoManager] disableUndoRegistration];
	
#ifdef DEBUG
	//NSLog(@"In addPicasaAlbums: %@",[[feed entries] count]);
#endif
	
	// Enumerate through new albums to add/update
	for (GDataEntryPhotoAlbum *newAlbum in [feed entries]) {
		BOOL found = NO;
		for (WAAlbum *album in self.albums) {
			
		//[newAlbum GPhotoID];
		//[newAlbum photosUsed];
		//[newAlbum name];
		
			if ([album.uniqueId longLongValue] == [[newAlbum GPhotoID] longLongValue]) {
				// Existing item found
				found = YES;
#ifdef DEBUG
				NSLog(@"Found existing album %@",album.uniqueId);
#endif
				//Update attributes
				album.name = [[newAlbum title] stringValue];
				album.cachedCount = [newAlbum photosUsed];
				album.path = [[[newAlbum feedLink] URL] absoluteString];
			} 
		}
		if (found == NO) {
			// newAlbum doesn't exist, create it
#ifdef DEBUG
			NSLog(@"New Album %@ found", [newAlbum name]);
#endif
			WAAlbum *buildAlbum = (WAAlbum *)[NSEntityDescription 
											  insertNewObjectForEntityForName:@"Album" 
											  inManagedObjectContext:moc];
			buildAlbum.name = [[newAlbum title] stringValue];
			buildAlbum.uniqueId = [NSNumber numberWithLongLong:[[newAlbum GPhotoID] longLongValue]];
			buildAlbum.cachedCount = [newAlbum photosUsed];
			buildAlbum.path = [[[newAlbum feedLink] URL] absoluteString];
			[self addAlbumsObject:buildAlbum];
		}
	}
	[moc save:&error];
	if (error) {
		NSLog(@"Error: %@", error);
	}
		
	// Now need to search the other way around to prune removed albums
	NSMutableSet *tbr = [NSMutableSet setWithCapacity:1];
	for (WAAlbum *album in self.albums) {
		BOOL found = NO;
		// Check for and add/remove Tagged Photos album

		for (GDataEntryPhotoAlbum *newAlbum in [feed entries]) {
			if ([album.uniqueId longLongValue] == [[newAlbum GPhotoID] longLongValue]) {
				found = YES;
			}
		}
		if (found == NO) {
			// Album no longer exists, prune it
#ifdef DEBUG
			NSLog(@"Found removed album, pruning %@", album);
#endif
			[tbr addObject:album];
		}
		
	}
	
	if ([tbr count]>0) {
		NSLog(@"%d albums to be removed", [tbr count]);
		[self removeAlbums:tbr];
	}
	
	[moc save:&error];
	if (error) {
		NSLog(@"Error: %@", error);
	}
	
	[[moc undoManager] enableUndoRegistration];
	
	// Notify delegate
	if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(accountAlbumsUpdated)]) {
		[delegate accountAlbumsUpdated];
	}    
	
	

}

-(void)addPicasaPhotos:(GDataFeedPhotoAlbum*)feed {
		// All newPhotos should belong to one album
		
		if ([feed entries] == nil) {
			return;
		}
		
		NSManagedObjectContext *moc = self.managedObjectContext;
		NSError *error = nil;
		WAAlbum *destAlbum;
		
		// Turn of undo management
		[[moc undoManager] disableUndoRegistration];
		
		//Determine which album these photos are for	
		NSEntityDescription *entityDescription = [NSEntityDescription 
												  entityForName:@"Album" inManagedObjectContext:moc]; 
		
		NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease]; 
		[request setEntity:entityDescription]; 
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueId=%@",[[feed firstEntry] albumID]];
		[request setPredicate:predicate];
		
		NSArray *result = [moc executeFetchRequest:request error:&error];
		if ([result count]>0) {
			destAlbum = [result objectAtIndex:0];
			NSLog(@"Found Album for photos: %@", destAlbum);
		}
	
		// Enumerate through new photos to add/update
		for (GDataEntryPhoto *newPhoto in [feed entries]) {
			BOOL found = NO;
			for (WAPhoto *photo in destAlbum.photos) {
				if ([photo.uniqueId longLongValue] == [[newPhoto GPhotoID] longLongValue]) {
					// Existing item found
					found = YES;
					NSLog(@"Found existing photo %@",photo.uniqueId);
					//Update attributes
					photo.thumbnailPath = [[[[newPhoto mediaGroup] mediaThumbnails] lastObject] URLString];
					photo.imagePath = [[[[newPhoto mediaGroup] mediaContents] objectAtIndex:0] URLString];
					photo.title = [[newPhoto title] stringValue];
					photo.someDate = [NSNumber numberWithDouble:[[[newPhoto timestamp] dateValue] timeIntervalSince1970]];
				} 
			}
			if (found == NO) {
				// newPhoto doesn't exist, create it
#ifdef DEBUG
				NSLog(@"New photo %@ found", [[newPhoto title] stringValue]);
#endif
				WAPhoto *buildPhoto = (WAPhoto *)[NSEntityDescription 
												  insertNewObjectForEntityForName:@"Photo" 
												  inManagedObjectContext:moc];
				buildPhoto.uniqueId = [NSNumber numberWithLongLong:[[newPhoto GPhotoID] longLongValue]];
				buildPhoto.title = [[newPhoto title] stringValue];
				buildPhoto.someDate = [NSNumber numberWithDouble:[[[newPhoto timestamp] dateValue] timeIntervalSince1970]];
				buildPhoto.wasViewed = [NSNumber numberWithBool:NO];
				buildPhoto.thumbnailPath = [[[[newPhoto mediaGroup] mediaThumbnails] objectAtIndex:0] URLString];
				buildPhoto.imagePath = [[[[newPhoto mediaGroup] mediaContents] objectAtIndex:0] URLString];
				NSLog(@"New photo for CoreData: %@", buildPhoto);
				[destAlbum addPhotosObject:buildPhoto];
			}
		}
		[moc save:&error];
		if (error) {
			NSLog(@"Save error: %@",error);
		}
		
		// Now need to search the other way around to make prune removed photos
		NSMutableSet *tbr = [NSMutableSet setWithCapacity:1];
		for (WAPhoto *photo in destAlbum.photos) {
			BOOL found = NO;
			for (GDataEntryPhoto *newPhoto in [feed entries]) {
				if ([photo.uniqueId longLongValue] == [[newPhoto GPhotoID] longLongValue]) {
					found = YES;
					// Leave it be
				}
			}
			if (found == NO) {
				// Photo no longer exists, prune it
				NSLog(@"Found removed photo, pruning %@", photo);
				[tbr addObject:photo];
			}
		}
		
		[destAlbum removePhotos:tbr];
		[moc save:&error];
		if (error) {
			NSLog(@"Save Error: %@", error);
		}
		
		[[moc undoManager] enableUndoRegistration];
		
		// Notify delegate
		if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(albumPhotosUpdated)]) {
			NSLog(@"Delegating");
			[self.delegate albumPhotosUpdated];
		}  
		
	}

#pragma mark Gallery Integration

-(NSNumber*)galleryHash:(ZWGalleryAlbum*)album {
	NSNumber *hash;
	hash = [NSNumber numberWithInt:[album.name intValue]];
	return hash;
}

-(void)addGalleryAlbums:(NSDictionary*)newAlbums {
	// Identify new albums and create new ones, update the photo count as well
	// There are nested albums on Gallery	
	// Need to fetch and assign thumbnail too
	
	// Album/Photo id in gallery is too basic, need to hash URL with ids to make better identifier
	
	if (newAlbums == nil) {
		return;
	}
	
	NSManagedObjectContext *moc = self.managedObjectContext;
	NSError *error = nil;
	
	// Turn of undo management
	[[moc undoManager] disableUndoRegistration];
	
    int numAlbums = [[newAlbums objectForKey:@"album_count"] intValue];
	
#ifdef DEBUG
	NSLog(@"In addGalleryAlbums: %@",newAlbums);
#endif
	// Enumerate through new albums to add/update
	for (int i=1; i<=numAlbums; i++) {
		NSString *aid = [newAlbums objectForKey:[NSString stringWithFormat:@"album.name.%i", i]];
		NSString *name = [newAlbums objectForKey:[NSString stringWithFormat:@"album.title.%i",i]];
		NSString *parent_aid = [newAlbums objectForKey:[NSString stringWithFormat:@"album.parent.%i",i]];
		BOOL found = NO;
		for (WAAlbum *album in self.albums) {
			if ([album.uniqueId longLongValue] == [aid longLongValue]) {
				// Exisiting item found
				found = YES;
#ifdef DEBUG
				NSLog(@"Found existing album %@",album.uniqueId);
#endif
				//Update attributes
				album.name = [NSString stringWithFormat:@"%@", name];
				album.path = parent_aid;
			} 
		}
		if (found == NO) {
			// newAlbum doesn't exist, create it
#ifdef DEBUG
			NSLog(@"New Album %@ found", name);
#endif
			WAAlbum *buildAlbum = (WAAlbum *)[NSEntityDescription 
											  insertNewObjectForEntityForName:@"Album" 
											  inManagedObjectContext:moc];
			buildAlbum.account = self;
			buildAlbum.name = name;
			buildAlbum.path = parent_aid;
			buildAlbum.uniqueId = [NSNumber numberWithLongLong:[aid longLongValue]];
			NSLog(@"Adding new album: %@", buildAlbum);
			[self addAlbumsObject:buildAlbum];
		}
	}
	[moc save:&error];
	if (error) {
		NSLog(@"Updated/Creating Albums Error: %@", error);
	}
		
	// Now need to search the other way around to prune removed albums
	NSMutableSet *tbr = [NSMutableSet setWithCapacity:1];
	for (WAAlbum *album in self.albums) {
		BOOL found = NO;
		// Check for and add/remove Tagged Photos album
		for (int i=1; i<=numAlbums; i++) {
			NSString *aid = [newAlbums objectForKey:[NSString stringWithFormat:@"album.name.%i", i]];
			if ([album.uniqueId longLongValue] == [aid longLongValue]) {
				found = YES;
			}
		}
		if (found == NO) {
			// Album no longer exists, prune it
#ifdef DEBUG
			NSLog(@"Found removed album, pruning %@", album);
#endif
			[tbr addObject:album];
		}
	}
	
	
	if ([tbr count]>0) {
		NSLog(@"%d albums to be removed", [tbr count]);
		[self removeAlbums:tbr];
	}
	
	[moc save:&error];
	if (error) {
		NSLog(@"Removing Albums Error: %@", error);
	}
	
	// Now need to set parents
	for (WAAlbum *album in self.albums) {
		// First check for blank parent pointer in path
		if (album.path == @"" | album.path == nil) {
		} else {
			// Find parent
			BOOL found = NO;
			for (WAAlbum *searchAlbum in self.albums) {
				if ([searchAlbum.uniqueId longLongValue] == [album.path longLongValue]) {
					found = YES;
					album.parent = searchAlbum;
				}
			}
			if (found==NO) {
			}
		}
	}
		
	[moc save:&error];
	if (error) {
		NSLog(@"Setting Parents Error: %@", error);
	}
		
	[[moc undoManager] enableUndoRegistration];
	
	// Notify delegate
	if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(accountAlbumsUpdated)]) {
		[delegate accountAlbumsUpdated];
	}    
}



- (void)addGalleryPhotos:(NSDictionary*)newPhotos toAlbum:(NSInteger)toAlbum {
	// All newPhotos should belong to one album
	
	if (newPhotos == nil) {
		return;
	}
	
	NSManagedObjectContext *moc = self.managedObjectContext;
	NSError *error = nil;
	WAAlbum *destAlbum;
	
	NSLog(@"Album: %i", toAlbum);
	
	// Turn of undo management
	[[moc undoManager] disableUndoRegistration];
	
	//Determine which album these photos are for	
	NSEntityDescription *entityDescription = [NSEntityDescription 
											  entityForName:@"Album" inManagedObjectContext:moc]; 
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease]; 
	[request setEntity:entityDescription]; 
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueId=%i",toAlbum];
	[request setPredicate:predicate];
	
	NSArray *result = [moc executeFetchRequest:request error:&error];
	if ([result count]>0) {
		destAlbum = [result objectAtIndex:0];
		NSLog(@"Found Album for photos: %@", destAlbum);
	} else {
		return;
	}
	
	if (![destAlbum.name isEqualToString:[newPhotos objectForKey:@"album.caption"]] ) {
		NSLog(@"Album caption does no match, abandoning");
		return;
	}
	
#ifdef DEBUG
	NSLog(@"In addGalleryPhotos: %@",newPhotos);
#endif
	// Enumerate through new photos to add/update
	NSString * accountUrl = [[newPhotos objectForKey:@"baseurl"] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
	NSLog(@"Original Base URL: %@", accountUrl);
	NSString * baseUrl = [NSString stringWithUTF8String:[[accountUrl stringByAppendingString:@"=core.DownloadItem&"] UTF8String]];
	NSLog(@"New Base URL: %@", baseUrl);
	NSInteger imageCount = [[newPhotos objectForKey:@"image_count"] intValue];
	for (NSInteger i=1; i<imageCount; i++) {
		BOOL found = NO;
		NSString *aid = [newPhotos objectForKey:[NSString stringWithFormat:@"image.name.%i", i]];
		NSString *thumb = [newPhotos objectForKey:[NSString stringWithFormat:@"image.thumbName.%i", i]];
		NSString *title = [newPhotos objectForKey:[NSString stringWithFormat:@"image.title.%i", i]];
		for (WAPhoto *photo in destAlbum.photos) {
			if ([photo.uniqueId longLongValue] == [aid longLongValue]) {
				// Existing item found
				found = YES;
				NSLog(@"Found existing photo %@",photo.uniqueId);
				//Update attributes
				photo.thumbnailPath = [NSString stringWithFormat:@"%@g2_itemId=%@", baseUrl, thumb];
				photo.imagePath = [NSString stringWithFormat:@"%@g2_itemId=%@", baseUrl, aid];
				photo.title = title;
				if ([photo.title isEqualToString:@"<null>"]) {
					photo.title=@"";
				}
				if (photo.someDate == nil) photo.someDate = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
				NSLog(@"Existing: %@", photo);
			} 
		}
		if (found == NO) {
			// newPhoto doesn't exist, create it
#ifdef DEBUG
			NSLog(@"New photo %@ found", [newPhotos objectForKey:[NSString stringWithFormat:@"image.title.%i", i]]);
#endif
			WAPhoto *buildPhoto = (WAPhoto *)[NSEntityDescription 
											  insertNewObjectForEntityForName:@"Photo" 
											  inManagedObjectContext:moc];
			buildPhoto.uniqueId = [NSNumber numberWithInt:[[newPhotos objectForKey:[NSString stringWithFormat:@"image.name.%i", i]] intValue]];
			buildPhoto.title = [NSString stringWithFormat:@"%@",[newPhotos objectForKey:[NSString stringWithFormat:@"image.title.%i", i]]];
			if ([buildPhoto.title isEqualToString:@"<null>"]) {
				buildPhoto.title = @"";
			}
			buildPhoto.wasViewed = [NSNumber numberWithBool:NO];
			buildPhoto.thumbnailPath = [NSString stringWithFormat:@"%@g2_itemId=%@", baseUrl, thumb];
			buildPhoto.imagePath =[NSString stringWithFormat:@"%@g2_itemId=%@", baseUrl, aid];
			buildPhoto.someDate = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
			NSLog(@"New photo for CoreData: %@", buildPhoto);
			[destAlbum addPhotosObject:buildPhoto];
		}
	}
	NSLog(@"Base URL: %@", baseUrl);
	
	[moc save:&error];
	if (error) {
		NSLog(@"Save error: %@",error);
	}
	
	// Now need to search the other way around to make prune removed photos
	NSMutableSet *tbr = [NSMutableSet setWithCapacity:1];
	for (WAPhoto *photo in destAlbum.photos) {
		BOOL found = NO;
		for (NSInteger i=1; i<imageCount; i++) {
			if ([photo.uniqueId longLongValue] == [[newPhotos objectForKey:[NSString stringWithFormat:@"image.name.%i", i]] longLongValue]) {
				found = YES;
				// Leave it be
			}
		}
		if (found == NO) {
			// Photo no longer exists, prune it
			NSLog(@"Found removed photo, pruning %@", photo);
			[tbr addObject:photo];
		}
	}
	
	[destAlbum removePhotos:tbr];
	[moc save:&error];
	if (error) {
		NSLog(@"Save Error: %@", error);
	}
	
	[[moc undoManager] enableUndoRegistration];
	
	// Notify delegate
	if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(albumPhotosUpdated)]) {
		NSLog(@"Delegating");
		[self.delegate albumPhotosUpdated];
	}  
	
}

@end
