//
//  NameEntryViewController.m
//  OnsiteTexts
//
//  Created by David Hodge on 9/7/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "NameEntryViewController.h"
#import "SessionManager.h"
#import "AppStateTransitioner.h"

@interface NameEntryViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldUnderlineHeight;

@end

@implementation NameEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor PrimaryAppColor];
    
    self.nameTextField.tintColor = [UIColor whiteColor];
    self.nameTextField.textColor = [UIColor whiteColor];
    
    [self.nameTextField addTarget:self action:@selector(checkTextFieldLength:) forControlEvents:UIControlEventEditingChanged];
    
    [self.submitButton setEnabled:NO];
    [self.submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.submitButton setTitleColor:[UIColor DisabledButtonColor] forState:UIControlStateDisabled];
    
    UIGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tgr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.textFieldUnderlineHeight.constant = 1.0 / [[UIScreen mainScreen] scale];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.nameTextField becomeFirstResponder];
}

- (IBAction)submit:(id)sender {

    if (self.nameTextField.text.length > 0)
    {
        [[SessionManager sharedSession] setName:self.nameTextField.text];
        
        [self.nameTextField resignFirstResponder];
        
        [AppStateTransitioner transitionToMainAppAnimated:YES];
    }
}

- (void)tap:(UIGestureRecognizer *)recognizer
{
    [self.nameTextField resignFirstResponder];
}

- (void)checkTextFieldLength:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    
    if (textField.text.length <= 0)
    {
        [self.submitButton setEnabled:NO];
    } else {
        [self.submitButton setEnabled:YES];
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
