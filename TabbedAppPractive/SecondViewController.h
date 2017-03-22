//
//  SecondViewController.h
//  TabbedAppPractive
//
//  Created by 張閎傑 on 3/14/17.
//  Copyright © 2017 hiimdoublej. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource,UITextViewDelegate,UITextFieldDelegate>

@property (strong,nonatomic) NSMutableArray *topLevelAdministrativeDivisions;
@property (strong,nonatomic) NSMutableDictionary *secondLevelAdministratiiveDivisions;

@property (strong, nonatomic) IBOutlet UILabel *loginPromptLabel;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UILabel *whenLabel;
@property (weak, nonatomic) IBOutlet UILabel *whereLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *DatePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *PickerView;
@property (weak, nonatomic) IBOutlet UITextField *PlateNumberTextBox;
@property (weak, nonatomic) IBOutlet UIButton *Submit;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *RateLabel;
@property (weak, nonatomic) IBOutlet UILabel *RatingValue;
@property (weak, nonatomic) IBOutlet UIStepper *RatingStepper;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderForCommentBox;
@property (weak, nonatomic) IBOutlet UITextField *plateNumberInput;
@property (weak, nonatomic) IBOutlet UILabel *AnyComments;
@property (weak, nonatomic) IBOutlet UILabel *PlateNumberText;



@property (strong,nonatomic) NSLock *lock;

@end

