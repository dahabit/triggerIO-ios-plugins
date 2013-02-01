//
//  database_API.h
//  ForgeModule
//
//  Created by explhorak on 12/17/12.
//  Copyright (c) 2012 Trigger Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface database_API : NSObject

// Creating all the initial tables
+ (void)createTables:(ForgeTask *)task queries:(NSArray *)queryString;

// For reading
+ (void)query:(ForgeTask *)task text:(NSString *)queryString;

// For writing
+ (void)writeAll:(ForgeTask *)task queries:(NSArray *)queryStrings;

// For CUDing entities such as #s and @s
+ (void)entityQuery:(ForgeTask *)task text:(NSString *)queryString type:(NSString *)queryType;

@end
