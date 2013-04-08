//
//  SKProduct+priceAsString.h
//  Saluton
//
//  Created by David Pettigrew on 4/5/13.
//  Copyright (c) 2013 Saluton. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface SKProduct (priceAsString)

@property (nonatomic, readonly) NSString *priceAsString;

@end
