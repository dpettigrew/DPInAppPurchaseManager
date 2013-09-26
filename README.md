DPInAppPurchaseManager iOS StoreKit Utility
===

This project consist of some iOS utility classes to support in-app purchase.

DPInAppPurchaseManager
---
The main class in DPInAppPurchaseManager. Use it as a singleton from 

`+ (DPInAppPurchaseManager *)sharedDPInAppPurchaseManager`

The API of the class is fairly self-explanatory

	- (void)loadIAPProducts:(NSSet *)productIdentifiers;
	- (BOOL)canMakePurchases;
	- (void)purchaseProduct:(SKProduct *)product;
	- (BOOL)hasProductBeenPurchased:(NSString *)productId;
	- (void)restorePurchases;

Calling `- (void)loadIAPProducts:(NSSet *)productIdentifiers` will load the SKProducts from the store. Generally you will call this method once on startup. It will start an SKProductsRequest sequence and notify the response via NSNotifications that include the SKProduct objects inside the userInfo NSDictionary.

Calling `- (void)purchaseProduct:(SKProduct *)product` with one of the SKProducts will similarly start a SKPaymentTransaction sequence and notify the response via NSNotifications that include the SKPaymentTransaction object inside the userInfo NSDictionary.

The library keeps the status of any purchases and their receipts inside NSUserDefaults. `- (BOOL)hasProductBeenPurchased:(NSString *)productId` allows a client to see if a product has been purchased already. 

`- (void)restorePurchases` will simply update the status for any purchased items and issue more responses via NSNotifications that include the SKProduct objects inside the userInfo NSDictionary.

UIViewController+DPInAppPurchase
---
Optional category that is useful if you want to be able to receive the DPInAppPurchaseManager notifications in multiple view controllers without having to register and unregister in each one. 
This does the NSNotificationCenter registration/unregistration for the relevant notifications that come from DPInAppPurchaseManager so only one view controller receives the notifications. You may want something different.

Call `- (void)becomeIAPResponder` in viewWillAppear
Call `- (void)resignIAPResponder` in viewWillDisappear
 
 i.e.
 
	- (void)viewWillAppear:(BOOL)animated {
 		[super viewWillAppear:animated];
 		[self becomeIAPResponder];
 	}
 
 	- (void)viewWillDisappear:(BOOL)animated {
 		[self resignIAPResponder];
 		[super viewWillDisappear:animated];
 	}

 You should override the methods below -

 	- (void)transactionFailed:(NSNotification *)notification;
 	- (void)productPurchased:(NSNotification *)notification;
 	- (void)productsFetched:(NSNotification *)notification;
 	- (void)invalidProductID:(NSNotification *)notification;
 	- (void)transactionSucceeded:(NSNotification *)notification;



