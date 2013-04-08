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

- (id)initWithProductId:(NSString *)productId
{
    self = [super init];
    if (self) {
        self.productID = productId;
        // restarts any purchases if they were interrupted last time the app was open
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        // get the product description (defined in early sections)
        [self requestUpgradeProductData];
    }
    return self;
}

- (void)requestUpgradeProductData
{
    NSSet *productIdentifiers = [NSSet setWithObject:self.productID ];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    _isGettingProducts = YES;
    [productsRequest start];
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    _isGettingProducts = NO;
    _gotProducts = YES;
    NSArray *products = response.products;
    self.skProduct = [products count] == 1 ? products[0] : nil;
    if (self.skProduct)
    {
        if ([self.delegate conformsToProtocol:@protocol(DPInAppPurchaseManagerDelegate)]) {
            [self.delegate didReceiveProduct:self.skProduct];
        }
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
}

#pragma mark 
//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
//
- (void)purchaseProduct
{
    if (self.skProduct) {
        SKPayment *payment = [SKPayment paymentWithProduct:self.skProduct];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else {
        NSLog(@"No product available");
    }
}

- (void)restoreProducts {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma -
#pragma Purchase helpers

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction {
    if ([transaction.payment.productIdentifier isEqualToString:self.productID])
    {
        // Delegate may want to save the transaction receipt on a server
        if ([self.delegate conformsToProtocol:@protocol(DPInAppPurchaseManagerDelegate)]) {
            [self.delegate didGetTransactionReceipt:transaction.transactionReceipt];
        }
    }
}

- (void)unlockFunctionality:(SKPaymentTransaction *)transaction {
    if ([transaction.payment.productIdentifier isEqualToString:self.productID])
    {
        if ([self.delegate conformsToProtocol:@protocol(DPInAppPurchaseManagerDelegate)]) {
            [self.delegate didBuyProductId:transaction.payment.productIdentifier];
        }
    }
}
- (void)provideProduct:(SKPaymentTransaction *)transaction {
    [self recordTransaction:transaction];
    [self unlockFunctionality:transaction];
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [self provideProduct:transaction];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [self provideProduct:transaction];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // notify the client of a failure
        if ([self.delegate conformsToProtocol:@protocol(DPInAppPurchaseManagerDelegate)]) {
            [self.delegate didFailToBuyProductId:transaction.originalTransaction.payment.productIdentifier error:transaction.error];
        }
        // remove the transaction from the payment queue.
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
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

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished:%@", queue);
}

@end
