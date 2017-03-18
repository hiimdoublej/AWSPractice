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
/**
*An ID for the data instance.
*/
@property (nonatomic, strong) NSString *DataID;
/**
The user's(who reported this ride) unique id.
*/
@property (nonatomic, strong) NSString *UserID;
/**
The platform of login that the user used.
*/
@property (nonatomic, strong) NSString *UserPlatform;
/**
The time of this report's submission.
*/
@property (nonatomic, strong) NSString *TimeSubmitted;
/**
The plate number of the cab.
*/
@property (nonatomic, strong) NSString *RideVehiclePlate;
/**
The date of the reported ride.
*/
@property (nonatomic, strong) NSString *RideTime;
/**
The location of the reported ride.
*/
@property (nonatomic, strong) NSString *RideLocation;
/**
User left messages.
*/
@property (nonatomic, strong) NSString *RideComment;
/**
An overall rating the user gave to this cab service.
*/
@property (nonatomic, strong) NSNumber *OverallRating;

//Those properties should be ignored according to ignoreAttributes
@property (nonatomic, strong) NSString *internalName;
@property (nonatomic, strong) NSNumber *internalState;


@end
