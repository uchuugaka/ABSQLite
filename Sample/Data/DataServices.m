//
//  DataServices.m
//  StressTest
//
//  Created by Aaron Bratcher on 06/28/2013.
//  Copyright (c) 2013 Aaron L. Bratcher. All rights reserved.
//

#import "DataServices.h"
#import "MobileDB.h"
#import "DownloadReportsOperation.h"
#import "DownloadLocationOperation.h"

NSString *const kLocationsUpdatedNotification = @"kLocationsUpdatedNotification";
NSString *const kReportsUpdatedNotification = @"kReportsUpdatedNotification";

static DataServices* _dataServices;

@interface DataServices()

@property (strong) NSMutableArray* downloadingLocations;
@property (strong) NSOperationQueue* downloadQueue;

@end

@implementation DataServices


-(id) init {
	if (!(self = [super init])) return nil;
	
	self.downloadingLocations = [[NSMutableArray alloc] init];
	self.downloadQueue = [[NSOperationQueue alloc] init];
	[self.downloadQueue setMaxConcurrentOperationCount:2];
	
	return self;
}

+(DataServices*) serviceInstance {
	if (!_dataServices) {
		_dataServices = [[DataServices alloc] init];
	}
	
	return _dataServices;
}

-(void) downloadReports {
	[[MobileDB dbInstance] allReports:^(NSArray *reports) {
		if (reports.count == 0) {
			DownloadReportsOperation* reportOperation = [[DownloadReportsOperation alloc] init];
			[self.downloadQueue addOperation:reportOperation];
		}
	}];
}

-(void) downloadLocations:(NSArray*) locations {
	NSMutableArray* locationArray = [[NSMutableArray alloc] init];
	
	for (NSNumber* locationID in locations) {
		if (![self.downloadingLocations containsObject:locationID]) {
			[locationArray addObject:locationID];
			[self.downloadingLocations addObject:locationID];
		}
	}
	[self retrieveLocations:locationArray];
}

-(void)retrieveLocations:(NSArray*) locations {
	DownloadLocationOperation* locationOperation = [[DownloadLocationOperation alloc] initWithLocations:locations];
	[self.downloadQueue addOperation:locationOperation];
}



@end
