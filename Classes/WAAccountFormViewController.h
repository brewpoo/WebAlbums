//
//  WAAccountFormViewController.h
//  WebAlbums
//
//  Created by JJL on 6/22/09.
//  Copyright 2009 NetGuyzApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WATableFormControl.h"
#import "WAAccount.h"

@interface WAAccountFormViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate> {
	UIBarButtonItem *cancelButton;
	UIBarButtonItem	*saveButton;
	UIButton		*deleteButton;
	NSMutableArray  *sections;
	WATableFormControl *accountNameElement;
	WATableFormControl *loginRequiredElement;
	WATableFormControl *userNameElement;
	WATableFormControl *passWordElement;
	WATableFormControl *emailElement;
	WATableFormControl *accountUrlElement;
	
	WAAccount *account;
}

@property (nonatomic, retain) UIBarButtonItem *cancelButton;
@property (nonatomic, retain) UIBarButtonItem *saveButton;
@property (nonatomic, retain) UIButton *deleteButton;
@property (nonatomic, retain) NSMutableArray *sections;
@property (nonatomic, retain) WATableFormControl *accountNameElement;
@property (nonatomic, retain) WATableFormControl *loginRequiredElement;
@property (nonatomic, retain) WATableFormControl *userNameElement;
@property (nonatomic, retain) WATableFormControl *passWordElement;
@property (nonatomic, retain) WATableFormControl *emailElement;
@property (nonatomic, retain) WATableFormControl *accountUrlElement;
@property (nonatomic, retain) WAAccount *account;

- (id)initWithAccount:(WAAccount *)account;

- (void)cancelAccount;
- (void)saveAccount;

- (void)accountEnabledUpdated:(UISwitch *)sender;
- (void)accountNameUpdated:(UITextField *)sender;
- (void)accountUrlUpdated:(UITextField *)sender;
- (void)userNameUpdated:(UITextField *)sender;
- (void)passWordUpdated:(UITextField *)sender;
- (void)emailUpdated:(UITextField *)sender;
- (void)loginRequiredUpdated:(UISwitch *)sender;
- (void)enableSaveIfValid;

@end
