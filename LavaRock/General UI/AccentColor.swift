//
//  AccentColor.swift
//  LavaRock
//
//  Created by h on 2020-07-29.
//

import SwiftUI
import UIKit

extension AccentColor: Identifiable {
	var id: Self { self }
}
enum AccentColor: CaseIterable {
	case blueberry
	case grape
	case strawberry
	case tangerine
	case lime
	
	static var preference: Self {
		get {
			defaults.register(defaults: [persistentKey: blueberry.persistentValue])
			let savedRawValue = defaults.string(forKey: persistentKey)!
			guard let matchingCase = allCases.first(where: { accentColorCase in
				savedRawValue == accentColorCase.persistentValue
			}) else {
				// Unrecognized persistent value
				return .blueberry
			}
			return matchingCase
		}
		set {
			defaults.set(newValue.persistentValue, forKey: persistentKey)
		}
	}
	
	var displayName: String {
		switch self {
			case .blueberry:
				return LRString.blueberry
			case .grape:
				return LRString.grape
			case .strawberry:
				return LRString.strawberry
			case .tangerine:
				return LRString.tangerine
			case .lime:
				return LRString.lime
		}
	}
	
	var color: Color {
		switch self {
			case .blueberry:
				return .blue
			case .grape:
				return .purple
			case .strawberry:
				return .pink
			case .tangerine:
				return .orange
			case .lime:
				return .green
		}
	}
	
	var uiColor: UIColor {
		switch self {
			case .blueberry:
				/*
				 # Light mode
				 
				 Hue (º): 215 - aiming low
				 Saturation (%): 100 - aiming high
				 Brightness (%): 75 - aiming low
				
				 # Dark mode
				 
				 H: 200 - aiming low
				 S: 70 - aiming low
				 B: 100 - aiming high
				 */
				return UIColor(named: "blueberry")!
				
			case .grape:
				/*
				 # Light mode
				 
				 H: 310 - aiming high
				 S: 100 - aiming high
				 B: 65 - aiming low
				 
				 # Dark mode
				 
				 H: 310 - aiming high
				 S: 50 - aiming low
				 B: 100 - aiming high
				 */
				return UIColor(named: "grape")!
				
			case .strawberry:
				/*
				 # Light mode
				 
				 H: 335 - aiming low
				 S: 100 - aiming high
				 B: 80 - aiming low
				 
				 # Dark mode
				 
				 H: 340 - aiming low
				 S: 60 - aiming low
				 B: 100 - aiming high
				 */
				return UIColor(named: "strawberry")!
				
			case .tangerine:
				/*
				 # Light mode
				 
				 H: 35 - aiming high
				 S: 100 - aiming high
				 B: 90 - aiming low
				 
				 # Dark mode
				 
				 H: 40 - aiming high
				 S: 70 - aiming low
				 B: 100 - aiming high
				 */
				return UIColor(named: "tangerine")!
				
			case .lime:
				/*
				 # Light mode
				 
				 H: 110 - aiming low
				 S: 100 - aiming high
				 B: 55 - aiming low
				 
				 # Dark mode
				 
				 H: 105 - aiming low
				 S: 50 - aiming low
				 B: 85 - aiming high
				 */
				return UIColor(named: "lime")!
		}
	}
	
	var heartEmoji: String {
		switch self {
			case .strawberry:
				return "❤️"
			case .tangerine:
				return "🧡"
			case .lime:
				return "💚"
			case .blueberry:
				return "💙"
			case .grape:
				return "💜"
		}
	}
	
	// MARK: - Private
	
	private static let defaults: UserDefaults = .standard
	private static let persistentKey: String = LRUserDefaultsKey.accentColor.rawValue
	
	private var persistentValue: String {
		switch self {
			case .lime:
				return "Lime"
			case .tangerine:
				return "Tangerine"
			case .strawberry:
				return "Strawberry"
			case .grape:
				return "Grape"
			case .blueberry:
				return "Blueberry"
		}
	}
}
