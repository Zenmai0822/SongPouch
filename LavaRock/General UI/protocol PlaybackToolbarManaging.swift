//
//  protocol PlaybackToolbarManaging.swift
//  LavaRock
//
//  Created by h on 2022-02-02.
//

import UIKit

@MainActor
protocol PlaybackToolbarManaging: PlayerReflecting {
	// Adopting types might want to …
	// • Override `accessibilityPerformMagicTap` and toggle playback.
	// However, as of iOS 15.4 developer beta 4, if no responder between the VoiceOver-focused element and the app delegate implements `accessibilityPerformMagicTap`, then VoiceOver toggles playback in the built-in Music app. https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/SupportingAccessibility.html
	var previousSongButton: UIBarButtonItem { get }
	var rewindButton: UIBarButtonItem { get }
	var skipBackwardButton: UIBarButtonItem { get }
	var playPauseButton: UIBarButtonItem { get }
	var skipForwardButton: UIBarButtonItem { get }
	var nextSongButton: UIBarButtonItem { get }
}
extension PlaybackToolbarManaging {
	var playbackToolbarButtons: [UIBarButtonItem] {
		if Enabling.playerScreen {
			return [
				previousSongButton, .flexibleSpace(),
				skipBackwardButton, .flexibleSpace(),
				playPauseButton, .flexibleSpace(),
				skipForwardButton, .flexibleSpace(),
				nextSongButton,
			]
		} else {
			return [
				previousSongButton, .flexibleSpace(),
				rewindButton, .flexibleSpace(),
				playPauseButton, .flexibleSpace(),
				nextSongButton,
			]
		}
	}
	
	func makePreviousSongButton() -> UIBarButtonItem {
		let button = UIBarButtonItem(
			title: LocalizedString.previousTrack,
			image: UIImage(systemName: "backward.end"),
			primaryAction: UIAction { [weak self] _ in
				self?.player?.skipToPreviousItem()
			})
		button.accessibilityTraits.formUnion(.startsMediaSession)
		return button
	}
	
	func makeRewindButton() -> UIBarButtonItem {
		let button = UIBarButtonItem(
			title: LocalizedString.restart,
			image: UIImage(systemName: "arrow.counterclockwise.circle"),
			primaryAction: UIAction { [weak self] _ in
				self?.player?.skipToBeginning()
			})
		button.accessibilityTraits.formUnion(.startsMediaSession)
		return button
	}
	
	func makeSkipBackwardButton() -> UIBarButtonItem {
		let button = UIBarButtonItem(
			title: LocalizedString.skip10SecondsBackwards,
			image: UIImage(systemName: "gobackward.10"),
			primaryAction: UIAction { [weak self] _ in
				self?.player?.currentPlaybackTime -= 10
			})
		button.accessibilityTraits.formUnion(.startsMediaSession)
		return button
	}
	
	func makeSkipForwardButton() -> UIBarButtonItem {
		let button = UIBarButtonItem(
			title: LocalizedString.skip10SecondsForward,
			image: UIImage(systemName: "goforward.10"),
			primaryAction: UIAction { [weak self] _ in
				self?.player?.currentPlaybackTime += 10
			})
		button.accessibilityTraits.formUnion(.startsMediaSession)
		return button
	}
	
	func makeNextSongButton() -> UIBarButtonItem {
		let button = UIBarButtonItem(
			title: LocalizedString.nextTrack,
			image: UIImage(systemName: "forward.end"),
			primaryAction: UIAction { [weak self] _ in
				self?.player?.skipToNextItem()
			})
		button.accessibilityTraits.formUnion(.startsMediaSession)
		return button
	}
	
	private func configurePlayButton() {
		playPauseButton.title = LocalizedString.play
		playPauseButton.primaryAction = UIAction(
			image: UIImage(systemName: "play.circle")
		) { [weak self] _ in
			self?.player?.play()
		}
		// As of iOS 15.3 developer beta 1, even when you set `UIBarButtonItem.width` manually, the “pause.fill” button is still narrower than the “play.fill” button.
		playPauseButton.accessibilityTraits.formUnion(.startsMediaSession)
	}
	
	func freshenPlaybackToolbar() {
		guard
			let player = player,
			!(Enabling.playerScreen && SongQueue.contents.isEmpty)
		else {
			configurePlayButton()
			playbackToolbarButtons.forEach { $0.disableWithAccessibilityTrait() }
			return
		}
		
		if player.playbackState == .playing {
			// Configure “pause” button
			playPauseButton.title = LocalizedString.pause
			playPauseButton.primaryAction = UIAction(
				image: UIImage(systemName: "pause.circle")
			) { [weak self] _ in
				self?.player?.pause()
			}
			playPauseButton.accessibilityTraits.subtract(.startsMediaSession)
		} else {
			configurePlayButton()
		}
		
		// Enable or disable each button as appropriate
		playbackToolbarButtons.forEach { $0.enableWithAccessibilityTrait() }
		if player.indexOfNowPlayingItem == 0 {
			previousSongButton.disableWithAccessibilityTrait()
		}
	}
}
