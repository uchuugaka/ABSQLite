//
//  EasySpendLogDB.m
//  Easy Spend Log
//
//  Created by Aaron Bratcher on 04/25/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MobileDB.h"
#import "ABSQLiteDB.h"
#import "ABLocation.h"
#import "NSString+Additions.h"

static MobileDB* _dbInstance;

@interface MobileDB()

@end

@implementation MobileDB {
	id <ABDatabase> db;
}


#pragma mark - Base

- (id) init {
	return [self initWithFile: NULL];
}

- (id) initWithFile: (NSString*) filePathName {
	if (!(self = [super init])) return nil;
	
	_dbInstance = self;
	
	BOOL myPathIsDir;
	BOOL fileExists = [[NSFileManager defaultManager]
							 fileExistsAtPath: filePathName
							 isDirectory: &myPathIsDir];
	
	// backupDbPath allows for a pre-made database to be in the app. Good for testing
	NSString *backupDbPath = [[NSBundle mainBundle]
									  pathForResource:@"Mobile"
									  ofType:@"db"];
	BOOL copiedBackupDb = NO;
	if (backupDbPath != nil) {
		copiedBackupDb = [[NSFileManager defaultManager]
								copyItemAtPath:backupDbPath
								toPath:filePathName
								error:nil];
	}
	
	// open SQLite db file
	db = [[ABSQLiteDB alloc] init];
	
	if(![db connect:filePathName]) {
		return nil;
	}
	
	if(!fileExists) {
		if(!backupDbPath || !copiedBackupDb)
			[self makeDB];
	}
	
	[self checkSchema]; // always check schema because updates are done here
	
	return self;
}

+ (MobileDB*) dbInstance {
	if (!_dbInstance) {
		NSString *dbFilePath;
		NSArray *searchPaths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentFolderPath = searchPaths[0];
		dbFilePath = [documentFolderPath stringByAppendingPathComponent: @"MobileDB.db"];
		
		MobileDB* mobileDB = [[MobileDB alloc] initWithFile:dbFilePath];
		if (!mobileDB) {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"File Error" message:@"Unable to open database." delegate:nil cancelButtonTitle:@"Darn" otherButtonTitles:nil];
			[alert show];
		}
	}
	
	return _dbInstance;
}


- (void) close {
	[db close];
}


#pragma mark - Locations
-(void) locationsForReport:(ABReport*) report Results:(LocationResultsBlock) locationsBlock {
	NSMutableArray* locations = [[NSMutableArray alloc] init];
	NSString* sql = [NSString stringWithFormat:@"select locationID from ReportLocations where reportID = %i",report.reportID];
	id<ABRecordset> results = [db sqlSelect:sql];
	while (![results eof]) {
		ABLocation* location = [[ABLocation alloc] init];
		location.locationID = [[results fieldWithName:@"locationID"] intValue];
		[locations addObject:location];
		
		[results moveNext];
	}
	
	locationsBlock(locations);
}


-(void) fillDetailsForLocations:(NSArray*) locations {
	for (ABLocation* location in locations) {
		NSString* sql = [NSString stringWithFormat:
							  @"select *"
							  " from locations"
							  " where locationID = %i"
							  ,location.locationID];
		
		id<ABRecordset> results = [db sqlSelect:sql];
		if ([results eof]) {
			location.address1 = @"Downloading...";
			continue;
		}
		
		location.clientLocationID = [[results fieldWithName:@"clientLocationID"] stringValue];
		location.address1 = [[results fieldWithName:@"address1"] stringValue];
		location.city = [[results fieldWithName:@"city"] stringValue];
		location.state = [[results fieldWithName:@"state"] stringValue];
		location.zip = [[results fieldWithName:@"zip"] stringValue];
		
		sql = [NSString stringWithFormat:
				 @"select name,value"
				 " from locationAttributes"
				 " where locationID = %i"
				 ,location.locationID];
		
		location.attributes = [[NSMutableDictionary alloc] init];
		results = [db sqlSelect:sql];
		while (![results eof]) {
			NSString* name = [[results fieldWithName:@"name"] stringValue];
			NSString* value = [[results fieldWithName:@"value"] stringValue];
			
			(location.attributes)[name] = value;
			[results moveNext];
		}
	}
}

-(void) saveLocation:(ABLocation*) location {
	NSString* sql;
	BOOL exists = NO;
	
	sql = [NSString stringWithFormat:@"select locationID from Locations where locationID = %i",location.locationID];
	id<ABRecordset> results = [db sqlSelect:sql];
	if (![results eof])
		exists = YES;
	
	if (exists) {
		sql = [NSString stringWithFormat:@"update Locations set address1 = '%@', city = '%@', state = '%@', zip = '%@' where locationID = %i",[self escapeText:location.address1], location.city, [self escapeText:location.state], location.zip, location.locationID];
	} else {
		sql = [NSString stringWithFormat:@"insert into Locations(locationID,clientLocationID,address1,city,state,zip) values(%i,'%@','%@','%@','%@','%@')",location.locationID,location.clientLocationID,[self escapeText:location.address1],[self escapeText:location.city],location.state,location.zip];
	}
	
	[db sqlExecute:sql];
}

#pragma mark - Reports

-(void) saveReport:(ABReport *)report {
	NSString* sql = [NSString stringWithFormat:@"select reportID from reports where reportID = %i",report.reportID];
	id<ABRecordset> results = [db sqlSelect:sql];
	if ([results eof]) {
		// add the report
		sql = [NSString stringWithFormat:@"insert into Reports(reportID,status) values(%i,'%@');",report.reportID,[self escapeText:report.status]];
		[db sqlExecute:sql];
	}
	
	if (report.locations) {
		for (NSNumber* locationID in report.locations) {
			sql = [NSString stringWithFormat:@"select locationID from ReportLocations where reportID = %i and locationID = %i",report.reportID,[locationID intValue]];
			results = [db sqlSelect:sql];
			
			if ([results eof]) {
				sql = [NSString stringWithFormat:@"insert into ReportLocations(reportID,locationID) values(%i,%i);",report.reportID,[locationID intValue]];
				[db sqlExecute:sql];
			}
		}
	}
}

-(void) allReports:(ReportResultsBlock)reportsBlock {
	NSMutableArray* reports = [[NSMutableArray alloc] init];
	NSString* sql = @"select reportID,status from Reports order by reportID";
	id<ABRecordset> results = [db sqlSelect:sql];
	while (![results eof]) {
		ABReport* report = [[ABReport alloc] init];
		report.reportID = [[results fieldWithName:@"reportID"] intValue];
		report.status = [[results fieldWithName:@"status"] stringValue];
		
		[reports addObject:report];
		[results moveNext];
	}
	
	reportsBlock(reports);
}

-(void) allReportsWithLocations:(ReportResultsBlock)reportsBlock {
	[self allReports:^(NSArray *reports) {
		for (ABReport* report in reports) {
			NSMutableArray* locations = [[NSMutableArray alloc] init];
			report.locations = locations;
			NSString* sql = [NSString stringWithFormat:@"select locationID from ReportLocations where reportID = %i",report.reportID];
			id<ABRecordset> results = [db sqlSelect:sql];
			while (![results eof]) {
				[locations addObject:@([[results fieldWithName:@"locationID"] intValue])];
				[results moveNext];
			}
		}
		
		reportsBlock(reports);
	}];
}


#pragma mark - Preferences

- (NSString*) preferenceForKey:(NSString *)key {
	NSString* preferenceValue = @"";
	
	NSString *sql = [NSString stringWithFormat:@"select value from preferences where property='%@';",key];
	
	id <ABRecordset> results;
	results = [db sqlSelect: sql];
	
	if (![results eof]) {
		preferenceValue = [[results fieldWithName:@"value"] stringValue];
	}
	
	return preferenceValue;
}


- (void) setPreference:(NSString *)value forKey:(NSString *)key {
	if (!value) {
		return;
	}
	
	NSString *sql = [NSString stringWithFormat:@"select value from preferences where property='%@';",key];
	
	id <ABRecordset> results;
	results = [db sqlSelect: sql];
	if ([results eof]) {
		sql = [NSString stringWithFormat:@"insert into preferences(property,value) values('%@','%@');",key,[self escapeText:value]];
	}
	else {
		sql = [NSString stringWithFormat:@"update preferences set value = '%@' where property = '%@';",[self escapeText: value],key];
	}
	
	[db sqlExecute:sql];
}


#pragma mark - Utilities

- (void) makeDB {
	// Locations
	[db sqlExecute:@"create table Locations(locationID int, clientLocationID text, address1 text, city text, state text, zip text, primary key(locationID));"];
	[db sqlExecute:@"create table LocationAttributes(locationID int, name text, value text, primary key(locationID,name));"];
	
	// Reports
	[db sqlExecute:@"create table Reports(reportID int, status text, primary key(reportID));"];
	[db sqlExecute:@"create table ReportLocations(reportID int, locationID int, primary key (reportID,locationID));"];
	
	// Internal
	[db sqlExecute:@"create table Preferences(property text, value text, primary key(property));"];
	
	[self setPreference:@"1" forKey:@"SchemaVersion"];
}

- (void) checkSchema {
	NSString* schemaVersion = [self preferenceForKey:@"SchemaVersion"];
	
	if([schemaVersion isEqualToString: @"1"]) {
		[db sqlExecute: @"create index idx_preferences_property on Preferences(property);"];
		[db sqlExecute: @"create index idx_locations_locationid on Locations(locationID);"];
		[db sqlExecute: @"create index idx_locationattributes_locationid on LocationAttributes(locationID);"];
		[db sqlExecute: @"create index idx_reports_reportid on Reports(reportID);"];
		[db sqlExecute: @"create index idx_reportlocations_reportid on ReportLocations(reportID);"];
		
		schemaVersion = @"2";
	}
	
	[db sqlExecute:@"ANALYZE"];
	
	[self setPreference:schemaVersion forKey:@"SchemaVersion"];
}

- (NSString *)uniqueID {
	CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
	NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
	CFRelease(uuid);
	
	return uuidString;
}

- (NSString*)escapeText:(NSString*)text {
	NSString* newValue = [text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
	return newValue;
}

@end
