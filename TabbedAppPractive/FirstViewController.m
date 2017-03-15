//
//  FirstViewController.m
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/14/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import "FirstViewController.h"


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
            
            queryExpression.hashKeyAttribute = @"RideVehiclePlate";
            queryExpression.hashKeyValues = targetPlate;
            queryExpression.exclusiveStartKey = self.lastEvaluatedKey;
            queryExpression.limit = @20;
            
            AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
            
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
                if(task.error)
                {
                    NSLog(@"AWS Error: [%@]", task.error);
                }
                [self.lock unlock];
                [activityIndicator stopAnimating];
                [self performSegueWithIdentifier:@"ToDetailView" sender:_tableRows];
                return nil;
            }];
        };
        return nil;
}

#pragma mark Search bar mechanics


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailViewController *dvc = segue.destinationViewController;
    dvc.tableRows = (NSMutableArray*)sender;
}
    
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
    {
        NSString *modified_text = searchBar.text.uppercaseString;
        NSLog(@"Searched with text %@",modified_text);
        [searchBar resignFirstResponder];//dismiss the keyboard
        [self AWSQuery:modified_text start_from_beginning:YES];
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
