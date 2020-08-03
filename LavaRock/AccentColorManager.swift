//
//  AccentColorManager.swift
//  LavaRock
//
//  Created by h on 2020-07-29.
//

import UIKit

struct AccentColorManager {
	
	static let accentColorTuples = [
		("Strawberry", UIColor.systemPink), // Magenta
//		("Red", UIColor.systemRed),
		("Tangerine", UIColor.systemOrange), // Orange
//		("Yellow", UIColor.systemYellow),
		("Lime", UIColor.systemGreen), // Green
//		("Cyan", UIColor.systemTeal),
		("Blueberry", UIColor.systemBlue), // Blue
//		("Indigo", UIColor.systemIndigo),
		("Grape", UIColor.systemPurple), // Violet
//		("None", UIColor.label),
	]
	
	static func uiColor(forName lookedUpName: String) -> UIColor? {
		if let (_, matchedUIColor) = accentColorTuples.first(where: { (savedName, _) in
			lookedUpName == savedName
		} ) {
			return matchedUIColor
		} else {
			return nil
		}
	}
	
	static func colorName(forUIColor lookedUpUIColor: UIColor) -> String? {
		if let (matchedColorName, _) = accentColorTuples.first(where: { (_, savedUIColor) in
			lookedUpUIColor == savedUIColor
		} ) {
			return matchedColorName
		} else {
			return nil
		}
	}
	
	static func colorName(forIndex index: Int) -> String? {
		guard (index >= 0) && (index <= accentColorTuples.count - 1) else {
			return nil
		}
		return accentColorTuples[index].0
	}
	
	static func uiColor(forIndex index: Int) -> UIColor? {
		guard (index >= 0) && (index <= accentColorTuples.count - 1) else {
			return nil
		}
		return accentColorTuples[index].1
	}
	
}
