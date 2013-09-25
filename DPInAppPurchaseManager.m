//
//  DPInAppPurchaseManager.m
//
//  Copyright (c) David Pettigrew. All rights reserved.
//  Based up on this code http://troybrant.net/blog/2010/01/in-app-purchases-a-full-walkthrough/
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

#import "DPInAppPurchaseManager.h"

@interface DPInAppPurchaseManager() {
    
}
@end

@implementation DPInAppPurchaseManager

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(DPInAppPurchaseManager)

- (void)requestUpgradeProductData:(NSSet *)productIdentifiers {
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    _productsRequest = nil;
    _gotProducts = YES;
    self.iapProducts = response.products;
    for (SKProduct *iapProduct in self.iapProducts) {
        NSLog(@"Product title: %@" , iapProduct.localizedTitle);
        NSLog(@"Product description: %@" , iapProduct.localizedDescription);
        NSLog(@"Product price: %@" , iapProduct.price);
        NSLog(@"Product id: %@" , iapProduct.productIdentifier);
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductFetchedNotification object:self userInfo:@{@"product": iapProduct}];
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers) {
        NSLog(@"Invalid product id: %@" , invalidProductId);
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerInvalidProductIDNotification object:self userInfo:@{@"invalidProductId": invalidProductId}];
    }
}

#pragma mark Public API
//
// call this method once on startup
//
- (void)loadIAPProducts:(NSSet *)productIdentifiers {
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description (defined in early sections)
    [self requestUpgradeProductData:productIdentifiers];
}

//
// call this before making a purchase
//
- (BOOL)canMakePurchases {
    return [SKPaymentQueue canMakePayments];
}

//
// kick off the transaction
//
- (void)purchaseProduct:(SKProduct *)product {
    if (product) {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else {
        NSLog(@"No product available");
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:nil];
    }
}

- (void)restorePurchases {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)saveTransactionReceipt:(SKPaymentTransaction *)transaction {
    if (transaction.payment.productIdentifier.length > 0) {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:[NSString stringWithFormat:@"%@-Receipt", transaction.payment.productIdentifier]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//
// record the purchase of the feature/content
//
- (void)recordProductPurchase:(NSString *)productId {
    if (productId.length > 0) {
        // record that the product is available
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@-Purchased", productId]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppProductPurchasedNotification object:self userInfo:@{@"productId": productId}];
    }
}

- (BOOL)hasProductBeenPurchased:(NSString *)productId {
    BOOL purchased = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@-Purchased", productId]];
    return purchased;
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful {
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful) {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [self saveTransactionReceipt:transaction];
    [self recordProductPurchase:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [self saveTransactionReceipt:transaction.originalTransaction];
    [self recordProductPurchase:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled) {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

@end
