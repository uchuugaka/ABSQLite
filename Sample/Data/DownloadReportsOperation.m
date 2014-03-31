//
//  ImportDataOperation.m
//  StressTest
//
//  Created by Aaron Bratcher on 06/28/2013.
//  Copyright (c) 2013 Aaron L. Bratcher. All rights reserved.
//

#import "DownloadReportsOperation.h"
#import "ABReport.h"
#import "MobileDB.h"
#import "DataServices.h"

@implementation DownloadReportsOperation

-(void) main {
	NSString* reportPath = [[NSBundle mainBundle] pathForResource:@"ABReports" ofType:@"txt"];
	NSString* reportJSON = [NSString stringWithContentsOfFile:reportPath encoding:NSUTF8StringEncoding error:nil];
	
	NSArray* reports = [ABReport reportsFromJSON:reportJSON];
	
	int index = 0;
	for (ABReport* report in reports) {
		[[MobileDB dbInstance] saveReport:report];
		[[DataServices serviceInstance] downloadLocations:report.locations];
		
		index++;

		if (index % 20 == 0) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[[NSNotificationCenter defaultCenter] postNotificationName:kReportsUpdatedNotification object:nil];
			});
		}
	}
}

@end
