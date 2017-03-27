//
//  DynamoDBActions.m
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/15/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import "DynamoDBActions.h"

static NSString *const AWSRetrieveDynamoDBTableName = @"LittleYellowPageDB0";
static NSString *const AWSReportDynamoDBTableName = @"LittleYellowPageDB1";
static BOOL isReporing = NO;
    
@implementation DynamoDBActions
    
+ (AWSTask *)describeTable {
    
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
    
    // See if the table exists.
    AWSDynamoDBDescribeTableInput *describeTableInput = [AWSDynamoDBDescribeTableInput new];
    describeTableInput.tableName = AWSRetrieveDynamoDBTableName;
    return [dynamoDB describeTable:describeTableInput];
}
    
+ (AWSTask *)createTable {
    AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
    
    // Create the test table.
    AWSDynamoDBAttributeDefinition *hashKeyAttributeDefinition = [AWSDynamoDBAttributeDefinition new];
    hashKeyAttributeDefinition.attributeName = @"DataID ";
    hashKeyAttributeDefinition.attributeType = AWSDynamoDBScalarAttributeTypeS;
    
    AWSDynamoDBKeySchemaElement *hashKeySchemaElement = [AWSDynamoDBKeySchemaElement new];
    hashKeySchemaElement.attributeName = @"UserId";
    hashKeySchemaElement.keyType = AWSDynamoDBKeyTypeHash;
    
    AWSDynamoDBAttributeDefinition *rangeKeyAttributeDefinition = [AWSDynamoDBAttributeDefinition new];
    rangeKeyAttributeDefinition.attributeName = @"TimeSubmitted";
    rangeKeyAttributeDefinition.attributeType = AWSDynamoDBScalarAttributeTypeS;
    
    AWSDynamoDBKeySchemaElement *rangeKeySchemaElement = [AWSDynamoDBKeySchemaElement new];
    rangeKeySchemaElement.attributeName = @"TimeSubmitted";
    rangeKeySchemaElement.keyType = AWSDynamoDBKeyTypeRange;
    
    //Add non-key attributes
    AWSDynamoDBAttributeDefinition *dateAttrDef = [AWSDynamoDBAttributeDefinition new];
    dateAttrDef.attributeName = @"Date";
    dateAttrDef.attributeType = AWSDynamoDBScalarAttributeTypeS;
    
    AWSDynamoDBAttributeDefinition *rideLocationAttrDef = [AWSDynamoDBAttributeDefinition new];
    rideLocationAttrDef.attributeName = @"RideLocation";
    rideLocationAttrDef.attributeType = AWSDynamoDBScalarAttributeTypeS;
    
    AWSDynamoDBProvisionedThroughput *provisionedThroughput = [AWSDynamoDBProvisionedThroughput new];
    provisionedThroughput.readCapacityUnits = @5;
    provisionedThroughput.writeCapacityUnits = @5;
    
    //Create Global Secondary Index
    NSArray *rangeKeyArray = @[@"Date",@"RideLocation"];
    NSMutableArray *gsiArray = [NSMutableArray new];
    for (NSString *rangeKey in rangeKeyArray) {
        AWSDynamoDBGlobalSecondaryIndex *gsi = [AWSDynamoDBGlobalSecondaryIndex new];
        
        AWSDynamoDBKeySchemaElement *gsiHashKeySchema = [AWSDynamoDBKeySchemaElement new];
        gsiHashKeySchema.attributeName = @"TimeSubmitted";
        gsiHashKeySchema.keyType = AWSDynamoDBKeyTypeHash;
        
        AWSDynamoDBKeySchemaElement *gsiRangeKeySchema = [AWSDynamoDBKeySchemaElement new];
        gsiRangeKeySchema.attributeName = rangeKey;
        gsiRangeKeySchema.keyType = AWSDynamoDBKeyTypeRange;
        
        AWSDynamoDBProjection *gsiProjection = [AWSDynamoDBProjection new];
        gsiProjection.projectionType = AWSDynamoDBProjectionTypeAll;
        
        gsi.keySchema = @[gsiHashKeySchema,gsiRangeKeySchema];
        gsi.indexName = rangeKey;
        gsi.projection = gsiProjection;
        gsi.provisionedThroughput = provisionedThroughput;
        
        [gsiArray addObject:gsi];
    }
    
    
    //Create TableInput
    AWSDynamoDBCreateTableInput *createTableInput = [AWSDynamoDBCreateTableInput new];
    createTableInput.tableName = AWSRetrieveDynamoDBTableName;
    createTableInput.attributeDefinitions = @[hashKeyAttributeDefinition, rangeKeyAttributeDefinition, dateAttrDef, rideLocationAttrDef];
    createTableInput.keySchema = @[hashKeySchemaElement, rangeKeySchemaElement];
    createTableInput.provisionedThroughput = provisionedThroughput;
    createTableInput.globalSecondaryIndexes = gsiArray;
    
    return [[dynamoDB createTable:createTableInput] continueWithSuccessBlock:^id(AWSTask *task) {
        if (task.result) {
            // Wait for up to 4 minutes until the table becomes ACTIVE.
            
            AWSDynamoDBDescribeTableInput *describeTableInput = [AWSDynamoDBDescribeTableInput new];
            describeTableInput.tableName = AWSRetrieveDynamoDBTableName;
            task = [dynamoDB describeTable:describeTableInput];
            
            for(int32_t i = 0; i < 16; i++) {
                task = [task continueWithSuccessBlock:^id(AWSTask *task) {
                    AWSDynamoDBDescribeTableOutput *describeTableOutput = task.result;
                    AWSDynamoDBTableStatus tableStatus = describeTableOutput.table.tableStatus;
                    if (tableStatus == AWSDynamoDBTableStatusActive) {
                        return task;
                    }
                    
                    sleep(15);
                    return [dynamoDB describeTable:describeTableInput];
                }];
            }
        }
        
        return task;
    }];
}

+ (void)setIsReporing:(BOOL)value
{
    isReporing = value;
}

@end

@implementation DDBTableRow
    
+ (NSString *)dynamoDBTableName {
    if(isReporing) return AWSReportDynamoDBTableName;
    
    return AWSRetrieveDynamoDBTableName;
}

+ (NSString *)dynamoDBTableName:(BOOL)isReporting {
    if(isReporting)
    {
        return AWSReportDynamoDBTableName;
    }
    return AWSRetrieveDynamoDBTableName;
}
    
+ (NSString *)hashKeyAttribute {
    //return @"UserID";
    return @"DataID";
}
    
//+ (NSString *)rangeKeyAttribute {
//    return @"";
//}

+ (NSArray *)ignoreAttributes {
    return @[@"internalName",@"internalState"];
}

@end

