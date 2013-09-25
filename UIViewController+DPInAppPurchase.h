//
//  UIViewController+DPInAppPurchase.h
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

#import <UIKit/UIKit.h>

/* Optional category that is useful if you want to be able to receive the DPInAppPurchaseManager notifications in multiple view controllers without having to register and unregister in each one.
 Call becomeIAPResponder in viewWillAppear
 Call becomeIAPResponder in viewWillDisappear
 
 i.e.
 
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 [self becomeIAPResponder];
 }
 
 - (void)viewWillDisappear:(BOOL)animated {
 [self resignIAPResponder];
 [super viewWillDisappear:animated];
 }

 You must implement the methods below if you use this as they will be called -

 - (void)transactionFailed:(NSNotification *)notification;
 - (void)productPurchased:(NSNotification *)notification;
 - (void)productsFetched:(NSNotification *)notification;
 - (void)invalidProductID:(NSNotification *)notification;
 - (void)transactionSucceeded:(NSNotification *)notification;

 */
@interface UIViewController (DPInAppPurchase)

- (void)becomeIAPResponder;
- (void)resignIAPResponder;

@end
