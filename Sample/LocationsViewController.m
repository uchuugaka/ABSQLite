//
//  LocationsViewController.m
//  StressTest
//
//  Created by Aaron Bratcher on 06/28/2013.
//  Copyright (c) 2013 Aaron L. Bratcher. All rights reserved.
//

#import "LocationsViewController.h"
#import "ABReport.h"
#import "ABLocation.h"
#import "MobileDB.h"
#import "LocationCell.h"

@interface LocationsViewController ()

@property (strong) NSArray* locations;

@end

@implementation LocationsViewController

-(id) initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	self.locations = [[NSArray alloc] init];
	return self;
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self locationsRefreshed:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationsRefreshed:) name:@"ReportViewSelected" object:nil];
}

-(void) locationsRefreshed:(NSNotification*)notification {
	self.locations = [[NSArray alloc] init];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.tableView reloadData];
	});
	
	ABReport* report = notification.object;
	[[MobileDB dbInstance] locationsForReport:report Results:^(NSArray *locations) {
		self.locations = locations;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.tableView reloadData];
		});
	}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"LocationCell";
	LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	ABLocation* location = self.locations[indexPath.row];
	if (!location.state) {
		[[MobileDB dbInstance] fillDetailsForLocations:@[location]];
	}
	cell.location = location;
	
	return cell;
}

@end
