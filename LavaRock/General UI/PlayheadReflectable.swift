//
//  PlayheadReflectable.swift
//  LavaRock
//
//  Created by h on 2020-11-07.
//

import UIKit

typealias PlayheadReflectable = _PlayheadReflectable & CachesBodyOfAccessibilityLabel

@MainActor
protocol CachesBodyOfAccessibilityLabel {
	var bodyOfAccessibilityLabel: String? { get }
}

@MainActor
protocol _PlayheadReflectable: AnyObject {
	// Adopting types must …
	// • Call `reflectPlayhead` whenever appropriate.
	
	var spacerSpeakerImageView: UIImageView! { get }
	var speakerImageView: UIImageView! { get }
	var accessibilityLabel: String? { get set }
}
extension _PlayheadReflectable {
	func reflectPlayhead(
		containsPlayhead: Bool,
		bodyOfAccessibilityLabel: String? // Force callers to pass this in manually, to help them remember to update it beforehand.
	) {
		spacerSpeakerImageView.maximumContentSizeCategory = .extraExtraExtraLarge
		speakerImageView.maximumContentSizeCategory = spacerSpeakerImageView.maximumContentSizeCategory
		
		spacerSpeakerImageView.image = UIImage(systemName: Avatar.current.playingSFSymbolName)
		
		let speakerImage: UIImage?
		let headOfAccessibilityLabel: String?
		defer {
			speakerImageView.image = speakerImage
			accessibilityLabel = [
				headOfAccessibilityLabel,
				bodyOfAccessibilityLabel,
			].compactedAndFormattedAsNarrowList()
		}
		
#if targetEnvironment(simulator)
		guard containsPlayhead else {
			speakerImage = nil
			headOfAccessibilityLabel = nil
			return
		}
		speakerImage = UIImage(systemName: Avatar.current.pausedSFSymbolName)
		headOfAccessibilityLabel = LRString.paused
#else
		guard
			containsPlayhead,
			let player = TapeDeck.shared.player
		else {
			speakerImage = nil
			headOfAccessibilityLabel = nil
			return
		}
		if player.playbackState == .playing {
			speakerImage = UIImage(systemName: Avatar.current.playingSFSymbolName)
			headOfAccessibilityLabel = LRString.nowPlaying
		} else {
			speakerImage = UIImage(systemName: Avatar.current.pausedSFSymbolName)
			headOfAccessibilityLabel = LRString.paused
		}
#endif
	}
}
