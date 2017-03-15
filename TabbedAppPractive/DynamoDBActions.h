//
//  DynamoDBActions.h
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/15/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@class DDBTableRow;

@interface DynamoDBActions : NSObject

+ (AWSTask *)describeTable;
+ (AWSTask *)createTable;
    
@end

@interface DDBTableRow : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *DataID;
@property (nonatomic, strong) NSString *UserID;
@property (nonatomic, strong) NSString *UserPlatform;
@property (nonatomic, strong) NSString *TimeSubmitted;
@property (nonatomic, strong) NSString *RideVehiclePlate;
@property (nonatomic, strong) NSString *RideTime;
@property (nonatomic, strong) NSString *RideLocation;
@property (nonatomic, strong) NSString *RideComment;
@property (nonatomic, strong) NSNumber *OverallRating;

//Those properties should be ignored according to ignoreAttributes
@property (nonatomic, strong) NSString *internalName;
@property (nonatomic, strong) NSNumber *internalState;

@end
