//
//  database_API.m
//  ForgeModule
//
//  Created by explhorak on 12/17/12.
//  Fetchnotes
//

#import "database_API.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@implementation database_API

// Takes JSONArray that contains strings to construct the database schema
+ (void)createTables:(ForgeTask *)task schema:(NSArray *)schema {
    
    // Locate Documents directory and open database.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    
    if (![database open]) {
        [task error: @"ERROR: createTables() was unable to open or create a database."];
    }
    [database open];
    
    // Iterate through the array and create a table with each name and then run the query
    for (NSDictionary * dataDict in schema) {
        NSString * NAME = [dataDict objectForKey:@"name"];
        NSString * SCHEMA = [dataDict objectForKey:@"schema"];
        NSString * QUERY = [NSString stringWithFormat:@"CREATE TABLE %@ %@", NAME, SCHEMA];
        [database executeUpdate:QUERY];
        NSLog(@"database.sql: %@", QUERY);
    }
    
    [database close];
    
    [task success: nil];
}

// Takes array of JSON objects with one attribute called query (string), and args (array of strings - only ever be of length 1))
+ (void)writeAll:(ForgeTask *)task queries:(NSArray *)queryStrings {
    
    // Locate Documents directory and open database.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    
    if (![database open]) {
        [task error: @"ERROR: createTables() was unable to open or create a database."];
    }
    [database open];
    
    // Iterate through each query and excuteUpdate()
    // Wrap int into a NSNumber to add to NSMutableArray
//    NSInteger count = [queryStrings count];
//    NSMutableArray *rowIds = [[NSMutableArray alloc] init];
//    int lastInsertRowId = 0;
//    for (int i = 0; i < count; i++) {
//        [database executeUpdate:queryStrings[i]];
//        lastInsertRowId = [database lastInsertRowId];
//        NSNumber *lastInsertRowIdInteger = [[NSNumber alloc] initWithInt:lastInsertRowId];
//        [rowIds addObject:lastInsertRowIdInteger];
//    }
//    
//    [database close];
//    NSLog(@"database.sql: %@", rowIds);
//    [task success: rowIds];
    
    //------------------------------------------------------------
    
    NSMutableArray *rowIds = [[NSMutableArray alloc] init];
    int lastInsertRowId = 0;
    
    for (NSDictionary *dataDict in queryStrings) {
        NSMutableArray *args = [dataDict objectForKey:@"args"];
        NSString *query = [dataDict objectForKey:@"query"];
        for (id item in args) {
            [database executeUpdate:query withArgumentsInArray:args];
            lastInsertRowId = [database lastInsertRowId];
            NSNumber *lastInsertRowIdInteger = [[NSNumber alloc] initWithInt:lastInsertRowId];
            [rowIds addObject:lastInsertRowIdInteger];
        }
    }
    [database close];
    
    // Serialize array data into a JSON object.
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:rowIds
                                                       options:kNilOptions
                                                         error:nil];
    
    // JSONArray of JSON objects
    NSString *strData = [[NSString alloc]initWithData:JSONData encoding:NSUTF8StringEncoding];

    
    
    NSLog(@"database.sql: %@", strData);
    [task success: strData];
}


// Returns the JSON array of note objects that match the passed in query.
+ (void)query:(ForgeTask *)task query:(NSString *)query {
    
    // Error handling.
    if ([query length] == 0) {
        [task error: @"Error: Query is 0 characters long"];
        return;
    }
    
    // Locate Documents directory and open database.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    
    // Pop all query results into an NSMutableArray & close database.
    NSMutableArray *resultsArray = [NSMutableArray array];
    FMResultSet *resultsSet = [database executeQuery:query];
    while ([resultsSet next]) {
        [resultsArray addObject:[resultsSet resultDictionary]];
    }
    [database close];
    
    // Serialize array data into a JSON object.
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:resultsArray
                                                       options:kNilOptions
                                                         error:nil];
    
    // JSONArray of JSON objects
    NSString *strData = [[NSString alloc]initWithData:JSONData encoding:NSUTF8StringEncoding];
    NSLog(@"database.sql: %@", strData);
    
    [task success:JSONData];
}

// Just drops all the tables in database, given an array of tables 
+ (void)dropTables:(ForgeTask *)task tables:(NSArray *)tables {
    // Locate Documents directory and open database.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    
    if (![database open]) {
        [task error: @"ERROR: createTables() was unable to open or create a database."];
    }
    
    [database open];
    
    // Iterate through the array and drop each table
    for (id item in tables) {
        NSString * query = [NSString stringWithFormat:@"DROP TABLE %@", item];
        [database executeUpdate:query];
        NSLog(@"database.sql: %@", query);
    }

    [database close];
    
    [task success: nil];
}

@end
