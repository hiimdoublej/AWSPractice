//
//  FirstViewController.m
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/14/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import "FirstViewController.h"
#import "RecordsNavigationController.h"


@interface FirstViewController ()
@property (nonatomic, readonly) NSMutableArray *tableRows;
@property (nonatomic, readonly) NSLock *lock;
@property (nonatomic, strong) NSDictionary *lastEvaluatedKey;
@property (nonatomic, assign) BOOL doneLoading;
@end

@implementation FirstViewController

#pragma mark View life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _tableRows = [NSMutableArray new];
    _lock = [NSLock new];
    
    [self.mySearchBar setDelegate:self];
    // Do any additional setup after loading the view, typically from a nib.
    if(![FBSDKAccessToken currentAccessToken])//no current access token, prompt login
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"ToFBLogin" sender:self];
        });
    }
    else//a current token in present, needs validation
    {
        [self validateCurrentFBToken];
    }
    NSLog(@"First View did load");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"First View did appear");
}

#pragma mark FaceBook related
-(void) validateCurrentFBToken
{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields":@"id,email"}];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSLog(@"request successful to graph api,token is valid");
            // handle successful response
        } else {
            NSLog(@"Error on validating current FB Token: %@", error);
        }
    }];
}

#pragma mark AWS related
- (AWSTask<NSDictionary<NSString *, NSString *> *> *)logins {
    FBSDKAccessToken* fbToken = [FBSDKAccessToken currentAccessToken];
    if(fbToken){
        NSString *token = fbToken.tokenString;
        return [AWSTask taskWithResult: @{ AWSIdentityProviderFacebook : token }];
    }else{
        return [AWSTask taskWithError:[NSError errorWithDomain:@"Facebook Login"
                                                          code:-1
                                                      userInfo:@{@"error":@"No current Facebook access token"}]];
    }
}

-(AWSTask*)AWSQuery:(NSString*)targetPlate start_from_beginning:(BOOL)startFromBeginning
{
    if([self.lock tryLock])
    {
        NSLog(@"Querying from dynamodb");
        //show activity indicator
        UIActivityIndicatorView *activityIndicator  =[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        [activityIndicator setCenter:CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0)];
        activityIndicator.hidesWhenStopped = YES;
        activityIndicator.color = [UIColor blackColor];
        
        //add the indicator to the view
        [self.view addSubview:activityIndicator];
        //start the indicator animation
        [activityIndicator startAnimating];
        if(startFromBeginning)
        {
            self.lastEvaluatedKey = nil;
            self.doneLoading = NO;
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
        queryExpression.indexName = @"RideVehiclePlate-index";
        
        queryExpression.keyConditionExpression = @"RideVehiclePlate = :targetPlate";
        queryExpression.expressionAttributeValues = @{@":targetPlate":targetPlate};
        
        //            deprecated methods
        //            queryExpression.hashKeyAttribute = @"RideVehiclePlate";
        //            queryExpression.hashKeyValues = targetPlate;
        
        queryExpression.exclusiveStartKey = self.lastEvaluatedKey;
        queryExpression.limit = @20;
        
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper;
        if([FBSDKAccessToken currentAccessToken])//token present,cognito identity authenticated by facebook
        {
            dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        }
        else//unauthenticated, use IP2UnAuthRole as objectmapper
        {
            dynamoDBObjectMapper = [AWSDynamoDBObjectMapper DynamoDBObjectMapperForKey:@"IP2UnAuthRole"];
        }
        return [[[dynamoDBObjectMapper query:[DDBTableRow class]
                                  expression:queryExpression]
                 continueWithExecutor:[AWSExecutor mainThreadExecutor] withSuccessBlock:
                 ^id(AWSTask *task)
                 {
                     if(!self.lastEvaluatedKey)
                     {
                         [self.tableRows removeAllObjects];
                     }
                     AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                     for(DDBTableRow *item in paginatedOutput.items)
                     {
                         [self.tableRows addObject:item];
                     }
                     self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey;
                     if(!paginatedOutput.lastEvaluatedKey)
                     {
                         self.doneLoading = YES;
                     }
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                     return nil;
                 }] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task)
                {
                    [self.lock unlock];
                    [activityIndicator stopAnimating];
                    if(task.error)
                    {
                        NSLog(@"AWS Error: [%@]", task.error);
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Error retrieving data from server. Please try again in a moment." preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
                        [alert addAction:defaultAction];
                        [self presentViewController:alert animated:YES completion:^(void){}];
                    }
                    else{
                        //task success
                        if([self.tableRows count] !=0)
                        {
                            [self performSegueWithIdentifier:@"ToRecordsView" sender:_tableRows];
                        }
                        else
                        {
                            NSLog(@"No records returen for plate : [%@]", targetPlate);
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"No previous reports with this plate number, if you had a ride with that cab, feel free to share your experience with others using the middle page !" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
                            [alert addAction:defaultAction];
                            [self presentViewController:alert animated:YES completion:^(void){}];
                        }
                    }
                    return nil;
                }];
    };
    return nil;
}

#pragma mark Search bar mechanics


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqual:@"ToRecordsView"])
    {
        RecordsNavigationController *rnc = segue.destinationViewController;
        RecordsViewController *rvc = (RecordsViewController*) rnc.topViewController;
        //type casting the above line to take the warning off
        rvc.tableRows = (NSMutableArray*)sender;
    }
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //setup alert first
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid input" message:@"Please check your input again." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    [alert addAction:defaultAction];
    //check the input into the search bar
    BOOL inputIsValid = NO;
    NSError *error = NULL;
    NSString *modified_text = searchBar.text.uppercaseString;
    if(modified_text.length<9 && modified_text.length>6)
    {//check using regular expression
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
        @"((([A-Z]|[0-9]){2,3}(-)([A-Z]|[0-9]){3,4}))" options:NSRegularExpressionCaseInsensitive error:&error];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:modified_text
                                                            options:0
                                                              range:NSMakeRange(0, [modified_text length])];
        NSLog(@"Searched with text:%@,regex numberOfMatches:%lu",modified_text,(unsigned long)numberOfMatches);
        inputIsValid = (numberOfMatches==1) ? YES:NO;
    }
    
    if(!inputIsValid)
    {
    //invalid input ->show alert
        [self presentViewController:alert animated:YES completion:^(void){}];
    }
    else
    {
    //valid input -> query
        [searchBar resignFirstResponder];//dismiss the keyboard
        [self AWSQuery:modified_text start_from_beginning:YES];
    }
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    NSLog(@"Cancel button clicked");
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"Stopped editing");
}

@end
