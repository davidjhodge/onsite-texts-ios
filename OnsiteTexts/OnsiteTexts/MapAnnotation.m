//
//  MapAnnotation.m
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation

+(instancetype)locationWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    MapAnnotation *mapAnnotation = [[MapAnnotation alloc] init];
    mapAnnotation.title = @"";
    mapAnnotation.subtitle = @"";
    mapAnnotation.coordinate = coordinate;
    
    return mapAnnotation;
}

@end
