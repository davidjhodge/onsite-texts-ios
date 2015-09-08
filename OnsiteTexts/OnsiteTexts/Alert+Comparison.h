//
//  Alert+Comparison.h
//  OnsiteTexts
//
//  Created by David Hodge on 9/6/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "Alert.h"

@interface Alert (Comparison)

/**
 *  Compares two alerts and determines if they have the same attributes.
 *
 *  @param alert    The alert to compare to.
 */
- (BOOL)isEqualToAlert:(Alert *)alert;

/**
 *  Looks in an array of alerts and gets a reference to the matching alert.
 *
 *  @param  array   Array of alerts to search through.
 */
- (Alert *)getMatchingAlertfromArray:(NSMutableArray *)array;

@end
