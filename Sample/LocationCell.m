//
//  LocationCell.m
//  StressTest
//
//  Created by Aaron Bratcher on 06/29/2013.
//  Copyright (c) 2013 Aaron L. Bratcher. All rights reserved.
//

#import "LocationCell.h"
#import "MobileDB.h"

@interface LocationCell()

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *zipLabel;

@end

@implementation LocationCell

-(void) setLocation:(ABLocation *)location {
	_location = location;
	if (!location.address1) {
		[[MobileDB dbInstance] fillDetailsForLocations:@[location]];
	}
	
	self.addressLabel.text = location.address1;
	self.cityLabel.text = location.city;
	self.stateLabel.text = location.state;
	self.zipLabel.text = location.zip;	
}

@end
