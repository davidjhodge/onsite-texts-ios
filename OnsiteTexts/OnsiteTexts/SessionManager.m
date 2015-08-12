//
//  SessionManager.m
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "SessionManager.h"

static SessionManager *sharedSession;

@implementation SessionManager

+(instancetype)sharedSession
{
    if (!sharedSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedSession = [[self alloc] init];
        });
    }
    
    return sharedSession;
}

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

@end
