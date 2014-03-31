

#import <Foundation/Foundation.h>
#import "ABLocation.h"

@interface ABReport : NSObject

@property (assign) int reportID;
@property (assign) int locationID;
@property (strong) NSMutableArray* locations;
@property (copy) NSString* status;

+(ABReport*)reportFromJSON:(NSString *)json;
+(NSArray*)reportsFromJSON:(NSString*)json;
-(NSString*)JSONValue;

@end
