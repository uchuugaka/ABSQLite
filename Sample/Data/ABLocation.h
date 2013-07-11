//
//  Location.h
//  MobileApp
//
//  Created by Aaron Bratcher on 12/06/2012.
//  Copyright (c) 2012 Market Force. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ABLocation : NSObject<MKAnnotation>

@property (assign) int locationID;

@property (copy) NSString* clientLocationID;
@property (copy) NSString* address1;
@property (copy) NSString* city;
@property (copy) NSString* state;
@property (copy) NSString* zip;
@property (strong) NSMutableDictionary* attributes;


+(ABLocation*) locationFromJSON:(NSString*) json;
+(NSArray*) locationsFromJSON:(NSString*) json;
-(NSString*) JSONValue;

@end
