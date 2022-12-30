//
//  UITableViewCell.swift
//  LavaRock
//
//  Created by h on 2021-08-22.
//

import UIKit

extension UITableViewCell {
	// Similar to counterpart in `UIBarButtonItem`.
	final func disableWithAccessibilityTrait() {
		isUserInteractionEnabled = false
		accessibilityTraits.formUnion(.notEnabled)
	}
	
	// Similar to counterpart in `UIBarButtonItem`.
	final func enableWithAccessibilityTrait() {
		isUserInteractionEnabled = true
		accessibilityTraits.subtract(.notEnabled)
	}
	
	final func tintSelectedBackgroundView() {
		let colorView = UIView()
		colorView.backgroundColor = .tintColor.withAlphaComponentOneHalf()
		selectedBackgroundView = colorView
	}
}
