//
//  CreditsViewController.m
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/23/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import "CreditsViewController.h"


@interface CreditsViewController ()

@end

@implementation CreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildAgreeTextViewFromLabel:self.label0];

    NSLog(@"CreditsViewDidLoad");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toFlaticon:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.flaticon.com/authors/madebyoliver"]];
}

- (IBAction)toAWS:(id)sender {
[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://aws.amazon.com/"]];
}

- (IBAction)isDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (void)buildAgreeTextViewFromLabel:(UILabel *)inputLabel
{
    NSString *localizedString = inputLabel.text;
    // 1. Split the localized string on the # sign:
    NSArray *localizedStringPieces = [localizedString componentsSeparatedByString:@"#"];
    
    // 2. Loop through all the pieces:
    NSUInteger msgChunkCount = localizedStringPieces ? localizedStringPieces.count : 0;
    CGPoint wordLocation = inputLabel.frame.origin;
    for (NSUInteger i = 0; i < msgChunkCount; i++)
    {
        NSString *chunk = [localizedStringPieces objectAtIndex:i];
        if ([chunk isEqualToString:@""])
        {
            continue;     // skip this loop if the chunk is empty
        }
        
        // 3. Determine what type of word this is:
        BOOL isFlaticonLink = [chunk hasPrefix:@"<flaticon>"];
        
        // 4. Create label, styling dependent on whether it's a link:
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:20.0f];
        label.text = chunk;
        label.userInteractionEnabled = isFlaticonLink;
        
        if (isFlaticonLink)
        {
            label.textColor = [UIColor blueColor];
            label.highlightedTextColor = [UIColor blueColor];
            
            // 5. Set tap gesture for this clickable text:
            SEL selectorAction = isFlaticonLink ? @selector(tapOnFlaticonLink:) : nil;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:selectorAction];
            [label addGestureRecognizer:tapGesture];
            
            // Trim the markup characters from the label:
            if(isFlaticonLink)
                label.text = [label.text stringByReplacingOccurrencesOfString:@"<flaticon>" withString:@""];
        }
        else
        {
            label.textColor = [UIColor blackColor];
        }
        
        // 6. Lay out the labels so it forms a complete sentence again:
        
        // If this word doesn't fit at end of this line, then move it to the next
        // line and make sure any leading spaces are stripped off so it aligns nicely:
        
        //[label sizeToFit];
        CGSize requiredSize = [[label text]sizeWithAttributes:@{@"NSFontAttributeName" : label.font}];
        
        if (self.view.frame.size.width < wordLocation.x + label.bounds.size.width)
        {
            wordLocation.x = 0.0;// move this word all the way to the left...
            wordLocation.y += label.frame.size.height;  // ...on the next line
            
            // And trim of any leading white space:
            NSRange startingWhiteSpaceRange = [label.text rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
            if (startingWhiteSpaceRange.location == 0)
            {
                label.text = [label.text stringByReplacingCharactersInRange:startingWhiteSpaceRange withString:@""];
                [label sizeToFit];
            }
        }
        
        // Set the location for this label:
        label.frame = CGRectMake(wordLocation.x,
                                 wordLocation.y,
                                 requiredSize.width,
                                 requiredSize.height);
        // Show this label:
        [self.view addSubview:label];
        // Update the horizontal position for the next word:
        wordLocation.x += label.frame.size.width;
    }
    [inputLabel removeFromSuperview];
}

- (void)tapOnFlaticonLink:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"User tapped");
    }
}


- (void)tapOnPrivacyPolicyLink:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"User tapped on the Privacy Policy link");
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
