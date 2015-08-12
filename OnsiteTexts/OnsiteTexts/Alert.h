//
//  Alert.h
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Alert : NSObject

/**
 *  The address of the alert represented as a string.
 */
@property (nonatomic, strong) NSString *address;

/**
 *  The contacts who will be notified by the alert contained in an array.
 */
@property (nonatomic, strong) NSArray *contacts;

@end
