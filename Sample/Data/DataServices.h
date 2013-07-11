//
//  DataServices.h
//  StressTest
//
//  Created by Aaron Bratcher on 06/28/2013.
//  Copyright (c) 2013 Aaron L. Bratcher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABLocation.h"

extern NSString *const kLocationsUpdatedNotification;
extern NSString *const kReportsUpdatedNotification;

@interface DataServices : NSObject

+(DataServices*) serviceInstance;
-(void) downloadReports;
-(void) downloadLocations:(NSArray*) locations;

@end
