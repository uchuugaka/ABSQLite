// NSString+Additions.h
#import <Foundation/Foundation.h>

@interface NSString (Additions)
-(BOOL) isIn: (NSString *) strings, ... NS_REQUIRES_NIL_TERMINATION;
-(NSString *)camelcaseString;
-(NSString *)capitalizeFirstLetterString;
-(NSString*) md5;
-(NSString*) sha1;
-(NSString*) sha2WithDigestLength:(int) length;
-(NSString*) encrypt;
-(NSString*) encryptWithSalt:(NSString*) salt;
-(NSDate*) dateValue;
-(NSString*) urlEncode;
-(NSString*) urlDecode;

@end