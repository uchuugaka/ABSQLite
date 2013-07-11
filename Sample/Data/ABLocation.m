#import "ABLocation.h"
#import "JSONDecoder.h"
#import "JSONEncoder.h"
#import "NSString+Additions.h"
#import "MobileDB.h"
#import "AppDelegate.h"


@interface ABLocation()<NSCoding>

@end

@implementation ABLocation

#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180

+(ABLocation*) locationFromJSON:(NSString *)json {
	ABLocation* location = [JSONDecoder decodeWithJSON:json];
	return location;
}

+(NSArray*) locationsFromJSON:(NSString*) json {
	NSArray* locations = [JSONDecoder decodeWithJSON:json];
	return locations;
}

-(NSString*)JSONValue {
	return [JSONEncoder JSONValueOfObject:self];
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
		self.locationID = [coder decodeIntForKey:@"locationID"];
		self.clientLocationID = [coder decodeObjectForKey:@"clientLocationID"];
		self.address1 = [coder decodeObjectForKey:@"address1"];
		self.city = [coder decodeObjectForKey:@"city"];
		self.state = [coder decodeObjectForKey:@"state"];
		self.zip = [coder decodeObjectForKey:@"zip"];
		self.attributes = [coder decodeObjectForKey:@"attributes"];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:self.locationID forKey:@"locationID"];
	[coder encodeObject:self.clientLocationID forKey:@"clientLocationID"];
	[coder encodeObject:self.address1 forKey:@"address1"];
	[coder encodeObject:self.city forKey:@"city"];
	[coder encodeObject:self.state forKey:@"state"];
	[coder encodeObject:self.zip forKey:@"zip"];
	[coder encodeObject:self.attributes forKey:@"attributes"];
}

- (BOOL) isEqual:(id)object {
	ABLocation* compareLocation = object;
	
	return self.locationID == compareLocation.locationID;
}

@end
