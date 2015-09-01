//
//  NSString+Address.h
//  OnsiteTexts
//
//  Created by David Hodge on 9/1/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Address)

/**
 *  Formats an address as a string given a street, city, and state.
 *
 *  @param  street  The street in the address.
 *  @param  city    The city the address is in.
 *  @param  state   The state the address is in.
 */
+ (NSString *)addressStringFromStreet:(NSString *)street city:(NSString *)city state:(NSString *)state;

@end
