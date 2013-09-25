//
//  DPInAppPurchaseManager.h
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

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "SKProduct+priceAsString.h"

#define kInAppPurchaseManagerProductFetchedNotification @"kInAppPurchaseManagerProductFetchedNotification"
#define kInAppPurchaseManagerInvalidProductIDNotification @"kInAppPurchaseManagerInvalidProductIDNotification"
// add a couple notifications sent out when the transaction completes
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"
#define kInAppProductPurchasedNotification @"kInAppProductPurchasedNotification"

@interface DPInAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProductsRequest *_productsRequest;
}

CWL_DECLARE_SINGLETON_FOR_CLASS(DPInAppPurchaseManager)

@property (strong, nonatomic) NSArray *iapProducts; //array of SKProduct *
@property BOOL gotProducts;

- (void)loadIAPProducts:(NSSet *)productIdentifiers;
- (BOOL)canMakePurchases;
- (void)purchaseProduct:(SKProduct *)product;
- (BOOL)hasProductBeenPurchased:(NSString *)productId;
- (void)restorePurchases;

@end
