//
//  ReportsViewController.m
//  StressTest
//
//  Created by Aaron Bratcher on 06/28/2013.
//  Copyright (c) 2013 Aaron L. Bratcher. All rights reserved.
//

#import "ReportsViewController.h"
#import "MobileDB.h"
#import "DataServices.h"

@interface ReportsViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong) NSArray* reports;
@property (assign) int lastSelectedRow;

@end

@implementation ReportsViewController

-(void) viewDidLoad {
	[super viewDidLoad];
	self.reports = [[NSArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self reportsRefreshed:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportsRefreshed:) name:kReportsUpdatedNotification object:nil];
}

-(void) viewDidDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) reportsRefreshed:(NSNotification*)notification {
	[[MobileDB dbInstance] allReports:^(NSArray *reports) {
		self.reports = reports;
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.tableView reloadData];
			if (self.lastSelectedRow) {
				NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.lastSelectedRow inSection:0];
				[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
			}
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
	return self.reports.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
	ABReport* report = self.reports[indexPath.row];
	cell.detailTextLabel.text = report.status;
	cell.textLabel.text = [NSString stringWithFormat:@"%i",report.reportID];
   
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.lastSelectedRow = indexPath.row;
	ABReport* report = self.reports[indexPath.row];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ReportViewSelected" object:report];
}


@end
