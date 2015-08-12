//
//  AlertCell.h
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertCell : UITableViewCell

/**
 *  The address that the alert will fire at.
 */
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

/**
 *  The people who will be notified when you reach the location.
 */
@property (weak, nonatomic) IBOutlet UILabel *contactsLabel;

@end
