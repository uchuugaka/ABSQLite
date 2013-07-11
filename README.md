ABSQLite is a different wrapper to SQLite for Objective-C.

There are 3 classes that conform to the ABDatabaseProtocols
There is a full example included that shows how the classes are used.

Quick start:
Copy the required files to your project
import "ABSQLiteDB.h

ABDatabase methods of interest:
(BOOL) connect:(NSString*)uri
(void) beginTransaction
(void) rollback
(void) commit
(void) sqlExecute:(NSString*)sql
(id<ABRecordset>) sqlSelect:(NSString*)sql

ABRecordset methods of interest:
(BOOL) eof
(id<ABField>) fieldWithName:(NSString*)fieldName;

ABField methods of interest:
- (NSString*) name;
- (BOOL) isNull;
- (BOOL) booleanValue;
- (NSString*) stringValue;
- (NSDate*) dateValue;
- (int) intValue;
- (double) doubleValue;
- (long long int) longLongValue;
- (NSData*) rawValue;

For some sample use, see the MobileDB class included in the project.

