//
//  SKProduct+priceAsString.m
//  Saluton
//
//  Created by David Pettigrew on 4/5/13.
//  Copyright (c) 2013 Saluton. All rights reserved.
//

#import "SKProduct+priceAsString.h"

@implementation SKProduct (priceAsString)

- (NSString *)priceAsString
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:[self priceLocale]];
    
    NSString *str = [formatter stringFromNumber:[self price]];
    return str;
}

@end
