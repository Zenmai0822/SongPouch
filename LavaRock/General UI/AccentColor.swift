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
				 Hue:
				 • 200 - approaching cyan
				 • 215 - GOOD. a tinge of yellow
				 • 235 - approaching purple
				 
				 # For hue 215
				 
				 Saturation:
				 • 0.80 - too desaturated
				 • 0.90 - dark mode: garish at any brightness
				 
				 Brightness:
				 • 0.65 - light mode: annoyingly dark
				 • 0.90 - dark mode: too dark
				 */
//				return UIColor( // Good in light mode, bad in dark mode
//					hue: 215/360, // Aiming low
//					saturation: 1.00, // Aiming high
//					brightness: 0.75, // Aiming low
//					alpha: 1)
//				return UIColor( // Good in dark mode
//					hue: 210/360, // Aiming low
//					saturation: 0.90, // Aiming high
//					brightness: 1.00, // Aiming high
//					alpha: 1)
				return UIColor(named: "blueberry")!
			case .grape:
				/*
				 Hue:
				 • 255 - too blue
				 • 280 - boring lavender
				 
				 • 315 - too close to Strawberry
				 • 325 - approaching maroon
				 
				 Saturation:
				 • 0.60 - too desaturated
				 • 0.90 - dark mode: too garish
				 
				 Brightness:
				 • 0.60 - light mode: barely different from black
				 • 0.95 - light mode: annoyingly bright. dark mode: boringly bright
				 */
//				return UIColor( // Good in light mode, bad in dark mode
//					hue: 310/360, // Aiming high
//					saturation: 1.00, // Aiming high
//					brightness: 0.65, // Aiming low
//					alpha: 1)
//				return UIColor( // Good in dark mode
//					hue: 310/360, // Aiming high
//					saturation: 0.70, // Aiming high
//					brightness: 1.00, // Aiming high
//					alpha: 1)
				return UIColor(named: "grape")!
			case .strawberry:
				/*
				 Hue:
				 • 335 - approaching maroon
				 • 350 - boring “classic red”
				 
				 Saturation:
				 • 0.80 - too desaturated
				 • 0.90 - dark mode: too garish
				 
				 Brightness:
				 • 0.75 - light mode: annoyingly dark
				 • 0.80 - dark mode: too dark
				 • 1.00 - boringly bright
				 */
//				return UIColor( // Good in light mode, bad in dark mode
//					hue: 335/360, // Aiming low
//					saturation: 1.00, // Aiming high
//					brightness: 0.80, // Aiming low
//					alpha: 1)
//				return UIColor( // Good in dark mode
//					hue: 335/360, // Aiming low
//					saturation: 0.80, // Aiming high
//					brightness: 1.00, // Aiming high
//					alpha: 1)
				return UIColor(named: "strawberry")!
			case .tangerine:
				/*
				 Hue:
				 • 25 - boring orange (the fruit)
				 • 45 - yellow
				 
				 Saturation:
				 • 0.75 - too desaturated
				 • 1.00 - still not garish
				 
				 Brightness:
				 • 0.90 - light mode: GOOD. dark mode: too dark
				 •
				 */
//				return UIColor( // Good in light mode, bad in dark mode
//					hue: 35/360, // Aiming high
//					saturation: 1.00, // Aiming high
//					brightness: 0.90, // Aiming low
//					alpha: 1)
//				return UIColor( // Good in dark mode
//					hue: 40/360, // Aiming high
//					saturation: 1.00, // Aiming high
//					brightness: 1.00, // Aiming high
//					alpha: 1)
				return UIColor(named: "tangerine")!
			case .lime:
				/*
				 Hue:
				 • 80 - browning guac
				 • 90 - annoyingly yellow
				 • 105 - distractingly yellow
				 
				 • 130 - light mode: canonical (boring) green, to me. i like yellower greens better here than bluer ones
				 • 145 - too blue
				 
				 Saturation:
				 •
				 
				 Brightness:
				 • 0.50 - light mode: annoyingly dark
				 • 0.75 - light mode: annoyingly bright
				 
				 • 0.85 - dark mode: annoyingly bright
				 */
//				return UIColor( // Good in light mode, bad in dark mode
//					hue: 110/360, // Aiming low
//					saturation: 1.00, // Aiming high
//					brightness: 0.55, // Aiming low
//					alpha: 1)
//				return UIColor( // Good in dark mode
//					hue: 110/360, // Aiming low
//					saturation: 0.65, // Aiming high
//					brightness: 0.85, // Aiming high
//					alpha: 1)
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
