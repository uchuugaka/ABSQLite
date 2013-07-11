{\rtf1\ansi\ansicpg1252\cocoartf1187\cocoasubrtf390
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\margl1440\margr1440\vieww16120\viewh12060\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural

\f0\b\fs24 \cf0 ABSQLite is a different wrapper to SQLite for Objective-C.\

\b0 \
There are 3 classes that conform to the ABDatabaseProtocols\
There is a full example included that shows how the classes are used.\
\
Quick start:\
Copy the required files to your project\
#import "ABSQLiteDB.h\
\
ABDatabase methods of interest:\
(BOOL) connect:(NSString*)uri\
(void) beginTransaction\
(void) rollback\
(void) commit\
(void) sqlExecute:(NSString*)sql\
(id<ABRecordset>) sqlSelect:(NSString*)sql\
\
ABRecordset methods of interest:\
(BOOL) eof\
(id<ABField>) fieldWithName:(NSString*)fieldName;\
\
ABField methods of interest:\
- (NSString*) name;\
- (BOOL) isNull;\
- (BOOL) booleanValue;\
- (NSString*) stringValue;\
- (NSDate*) dateValue;\
- (int) intValue;\
- (double) doubleValue;\
- (long long int) longLongValue;\
- (NSData*) rawValue;\
\
For some sample use, see the MobileDB class included in the project.\
\
}