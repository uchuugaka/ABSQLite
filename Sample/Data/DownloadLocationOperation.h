//
//  DownloadLocationOperation.h
//  StressTest
//
//  Created by Aaron Bratcher on 06/28/2013.
//  Copyright (c) 2013 Aaron L. Bratcher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadLocationOperation : NSOperation

-(id) initWithLocations:(NSArray*) locations;

@end
