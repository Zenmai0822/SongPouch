//
//  PurchaseManager.swift
//  LavaRock
//
//  Created by h on 2020-12-27.
//

import StoreKit

protocol PurchaseManagerTipDelegate: AnyObject {
	func didReceiveTipProduct(_ tipProduct: SKProduct)
	func didFailToReceiveTipProduct()
	func didUpdateTipTransaction(_ tipTransaction: SKPaymentTransaction)
}

final class PurchaseManager: NSObject {
	
	// MARK: Types
	
	enum ProductIdentifier: String, CaseIterable {
		case tip = "com.loudsounddreams.LavaRock.tip"
	}
	
	// MARK: Properties
	
	// Constants
	static let shared = PurchaseManager()
	
	// Variables
	
	
//	var isFirstTimeRequestingAllSKProducts = true
	
	
	lazy var savedSKProductsRequest: SKProductsRequest? = nil
	lazy var priceFormatter: NumberFormatter? = nil
	lazy var tipProduct: SKProduct? = nil
	weak var tipDelegate: PurchaseManagerTipDelegate?
	
	// MARK: Setup and Teardown
	
	private override init() { }
	
	deinit {
		endObservingPaymentTransactions()
	}
	
	final func beginObservingPaymentTransactions() {
		SKPaymentQueue.default().add(self)
	}
	
	private func endObservingPaymentTransactions() {
		SKPaymentQueue.default().remove(self)
	}
	
	// MARK: Other
	
	final func requestAllSKProducts() {
		var setOfIdentifiers = Set<String>()
		for identifier in ProductIdentifier.allCases {
			setOfIdentifiers.insert(identifier.rawValue)
		}
		let productsRequest = SKProductsRequest(productIdentifiers: setOfIdentifiers)
		productsRequest.delegate = self
		productsRequest.start()
		savedSKProductsRequest = productsRequest
	}
	
	final func addToPaymentQueue(_ skProduct: SKProduct?) {
		guard let skProduct = skProduct else { return }
		let skPayment = SKPayment(product: skProduct)
//		let skPayment = SKMutablePayment(product: skProduct)
//		skPayment.simulatesAskToBuyInSandbox = true
		SKPaymentQueue.default().add(skPayment)
	}
	
}

extension PurchaseManager: SKProductsRequestDelegate {
	
	final func productsRequest(
		_ request: SKProductsRequest,
		didReceive response: SKProductsResponse
	) {
//		if isFirstTimeRequestingAllSKProducts {
//			isFirstTimeRequestingAllSKProducts = false
//
//
//			if request == savedSKProductsRequest {
//				for identifier in ProductIdentifier.allCases {
//					switch identifier {
//					case .tip:
//						tipDelegate?.didFailToReceiveTipProduct()
//					}
//				}
//			}
//
//
//			return
//		}
		
		
		if let priceLocale = response.products.first?.priceLocale {
			setUpPriceFormatter(locale: priceLocale)
		}
		for product in response.products {
			switch product.productIdentifier {
			case ProductIdentifier.tip.rawValue:
				self.tipProduct = product
				self.tipDelegate?.didReceiveTipProduct(product)
			default:
				break
			}
		}
	}
	
	final func request(
		_ request: SKRequest,
		didFailWithError error: Error
	) {
		if request == savedSKProductsRequest {
			for identifier in ProductIdentifier.allCases {
				switch identifier {
				case .tip:
					tipDelegate?.didFailToReceiveTipProduct()
				}
			}
		}
	}
	
	private func setUpPriceFormatter(locale: Locale) {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.locale = locale
		priceFormatter = formatter
	}
	
}

extension PurchaseManager: SKPaymentTransactionObserver {
	
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		for transaction in transactions {
			switch transaction.payment.productIdentifier {
			case ProductIdentifier.tip.rawValue:
				tipDelegate?.didUpdateTipTransaction(transaction)
			default:
				break
			}
		}
	}
	
}
