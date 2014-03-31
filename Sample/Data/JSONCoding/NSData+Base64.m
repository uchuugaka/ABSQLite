//
//  NSData+Base64.m
//  base64
//
//  Created by Matt Gallagher on 2009/06/03.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "NSData+Base64.h"


@implementation NSData (Base64)


+ (NSData *)dataFromBase64String:(NSString *)string
{
	unsigned long ixtext, lentext;
	unsigned char ch, inbuf[4], outbuf[3];
	short i, ixinbuf;
	Boolean flignore, flendtext = false;
	const unsigned char *tempcstring;
	NSMutableData *theData;
	
	if (string == nil)
	{
		return [NSData data];
	}
	
	ixtext = 0;
	
	tempcstring = (const unsigned char *)[string UTF8String];
	
	lentext = [string length];
	
	theData = [NSMutableData dataWithCapacity: lentext];
	
	ixinbuf = 0;
	
	while (true)
	{
		if (ixtext >= lentext)
		{
			break;
		}
		
		ch = tempcstring [ixtext++];
		
		flignore = false;
		
		if ((ch >= 'A') && (ch <= 'Z'))
		{
			ch = ch - 'A';
		}
		else if ((ch >= 'a') && (ch <= 'z'))
		{
			ch = ch - 'a' + 26;
		}
		else if ((ch >= '0') && (ch <= '9'))
		{
			ch = ch - '0' + 52;
		}
		else if (ch == '+')
		{
			ch = 62;
		}
		else if (ch == '=')
		{
			flendtext = true;
		}
		else if (ch == '/')
		{
			ch = 63;
		}
		else
		{
			flignore = true;
		}
		
		if (!flignore)
		{
			short ctcharsinbuf = 3;
			Boolean flbreak = false;
			
			if (flendtext)
			{
            if (ixinbuf == 0)
            {
					break;
            }
				
            if ((ixinbuf == 1) || (ixinbuf == 2))
            {
					ctcharsinbuf = 1;
            }
            else
            {
					ctcharsinbuf = 2;
            }
				
            ixinbuf = 3;
				
            flbreak = true;
			}
			
			inbuf [ixinbuf++] = ch;
			
			if (ixinbuf == 4)
			{
            ixinbuf = 0;
				
            outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
            outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
            outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
				
            for (i = 0; i < ctcharsinbuf; i++)
            {
					[theData appendBytes: &outbuf[i] length: 1];
            }
			}
			
			if (flbreak)
			{
            break;
			}
		}
	}
	
	return theData;
}

//
// base64EncodedString
//
// Creates an NSString object that contains the base 64 encoding of the
// receiver's data. Lines are broken at 64 characters long.
//
// returns an autoreleased NSString being the base 64 representation of the
//	receiver.
//
- (NSString *)base64EncodedString
{
	NSData* theData = self;
   const uint8_t* input = (const uint8_t*)[theData bytes];
	NSInteger length = [theData length];
	
	static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
	NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
	uint8_t* output = (uint8_t*)data.mutableBytes;
	
	NSInteger i;
	for (i=0; i < length; i += 3) {
		NSInteger value = 0;
		NSInteger j;
		for (j = i; j < (i + 3); j++) {
			value <<= 8;
			
			if (j < length) {
				value |= (0xFF & input[j]);
			}
		}
		
		NSInteger theIndex = (i / 3) * 4;
		output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
		output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
		output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
		output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
	}
	
	return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
