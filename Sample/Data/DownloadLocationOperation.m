//
//  DownloadLocationOperation.m
//  StressTest
//
//  Created by Aaron Bratcher on 06/28/2013.
//  Copyright (c) 2013 Aaron L. Bratcher. All rights reserved.
//


#import "DownloadLocationOperation.h"
#import "MobileDB.h"
#import "ABLocation.h"
#import "DataServices.h"

static NSArray* locationCache;

@interface DownloadLocationOperation()

@property (strong) NSArray* locations;

@end


@implementation DownloadLocationOperation

-(id) initWithLocations:(NSArray *)locations {
	if (!(self = [super init])) return nil;
	
	self.locations = locations;
	return self;
}

-(void) main {
	/*
	 
	 Why this elaborate way to load the locations?
	 
	 Because this tiny app is modeled after a much larger one that downloads the data from an internet service.
	 Like this app, reports are downloaded first, then locations associated with those reports
	 one at a time. So this is to simulate that internet download process and how it is not immediate.
	 
	 */
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSString* locationPath = [[NSBundle mainBundle] pathForResource:@"ABLocations" ofType:@"txt"];
		NSString* locationJSON = [NSString stringWithContentsOfFile:locationPath encoding:NSUTF8StringEncoding error:nil];
		
		locationCache = [ABLocation locationsFromJSON:locationJSON];
	});
	
	NSNumber* lastNumber = self.locations[self.locations.count-1];
	
	for (NSNumber* locationID in self.locations) {
		ABLocation* location = [[ABLocation alloc] init];
		location.locationID = [locationID intValue];
		
		int index = [locationCache indexOfObject:location];
		location = locationCache[index];
		[[MobileDB dbInstance] saveLocation:location];
		
		if ([locationID isEqualToNumber:lastNumber]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[[NSNotificationCenter defaultCenter] postNotificationName:kLocationsUpdatedNotification object:nil];
			});
		}
	}	
}

@end
