//
//  MFIReport.m
//  MobileApp
//
//  Created by Aaron Bratcher on 12/13/2012.
//  Copyright (c) 2012 Market Force. All rights reserved.
//

#import "ABReport.h"
#import "JSONEncoder.h"
#import "JSONDecoder.h"
#import "NSString+Additions.h"
#import "NSData+Base64.h"

@interface ABReport()<NSCoding>

@end

@implementation ABReport


+(ABReport*)reportFromJSON:(NSString *)json {
	ABReport* report = [JSONDecoder decodeWithJSON:json];
	return report;
}

+(NSArray*) reportsFromJSON:(NSString*) json {
	NSArray* reports = [JSONDecoder decodeWithJSON:json];
	return reports;
}

-(NSString*)JSONValue {
	return [JSONEncoder JSONValueOfObject:self];
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
		self.reportID = [coder decodeIntForKey:@"reportID"];
		self.status = [coder decodeObjectForKey:@"status"];
		self.locations = [coder decodeObjectForKey:@"locations"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:self.reportID forKey:@"reportID"];
	[coder encodeObject:self.status forKey:@"status"];
	[coder encodeObject:self.locations forKey:@"locations"];
}

- (BOOL) isEqual:(id)object {
	ABReport* compareReport = object;
	
	return self.reportID == compareReport.reportID;
}

- (void) addLocation:(ABLocation *)location {
	[self.locations addObject:location];
}


@end
