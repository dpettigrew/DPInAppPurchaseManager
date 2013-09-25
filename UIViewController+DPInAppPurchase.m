//
//  UIViewController+DPInAppPurchase.m
//  Saluton
//
//  Created by David Pettigrew on 9/25/13.
//  Copyright (c) David Pettigrew. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//      * Neither the name of the David Pettigrew nor the
//        names of its contributors may be used to endorse or promote products
//        derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL David Pettigrew BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "UIViewController+DPInAppPurchase.h"
#import "DPInAppPurchaseManager.h"

@implementation UIViewController (DPInAppPurchase)

- (void)resignIAPResponder {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInAppPurchaseManagerTransactionFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInAppProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInAppPurchaseManagerProductFetchedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInAppPurchaseManagerInvalidProductIDNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];
    
}

- (void)becomeIAPResponder {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionFailed:) name:kInAppPurchaseManagerTransactionFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kInAppProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productFetched:) name:kInAppPurchaseManagerProductFetchedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidProductID:) name:kInAppPurchaseManagerInvalidProductIDNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionSucceeded:) name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];
}

// Sample code
// Your UIViewControllers should override these

- (void)transactionFailed:(NSNotification *)notification {
    SKPaymentTransaction *transaction = [notification.userInfo valueForKey:@"transaction"];
    NSLog(@"transactionFailed - transaction: %@ ", transaction);
    // Add custom code after here
}

- (void)productPurchased:(NSNotification *)notification {
    NSString *productId = [notification.userInfo valueForKey:@"productId"];
    NSLog(@"productPurchased - productId: %@ ", productId);
    // Add custom code after here
}

- (void)productFetched:(NSNotification *)notification  {
    SKProduct *product = [notification.userInfo valueForKey:@"product"];
    NSLog(@"product: %@ ", product);
    // Add custom code after here
}

- (void)invalidProductID:(NSNotification *)notification  {
    NSString *invalidProductID = [notification.userInfo valueForKey:@"invalidProductID"];
    NSLog(@"invalidProductID: %@ ", invalidProductID);
    // Add custom code after here
}

- (void)transactionSucceeded:(NSNotification *)notification {
    SKPaymentTransaction *transaction = [notification.userInfo valueForKey:@"transaction"];
    NSLog(@"transactionSucceeded - transaction: %@ ", transaction);
    // Add custom code after here
}

@end
