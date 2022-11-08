//
//  MainToolbar.swift
//  LavaRock
//
//  Created by h on 2022-05-09.
//

import UIKit
import MediaPlayer

// Instantiators might want to …
// • Implement `accessibilityPerformMagicTap` and toggle playback.
// However, as of iOS 15.4 developer beta 4, if no responder between the VoiceOver-focused element and the app delegate implements `accessibilityPerformMagicTap`, then VoiceOver toggles audio playback. https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/SupportingAccessibility.html
@MainActor
final class MainToolbar {
	private static var player: MPMusicPlayerController? { TapeDeck.shared.player }
	
	private let showConsoleButton: UIBarButtonItem
	
	private lazy var moreButton: UIBarButtonItem = {
		let button = UIBarButtonItem(
			title: LRString.more,
			image: Self.more_button_default_image,
			menu: UIMenu(
				title: "",
				presentsUpward: true,
				menuElementGroups: [
					[
						UIAction(
							title: LRString.openMusic,
							image: UIImage(systemName: "arrow.up.forward.app"),
							handler: { action in
								UIApplication.shared.open(.music)
							}
						),
					],
					
					[
						UIMenu(
							options: [
								.displayInline,
							],
							preferredElementSize: .small,
							children: [
								UIDeferredMenuElement.uncached({ useMenuElements in
									let action = UIAction(
										title: LRString.repeatOff,
										image: UIImage(systemName: "minus"),
										attributes: {
											var result: UIMenuElement.Attributes = []
											if (Self.player == nil) || (Self.player?.repeatMode == MPMusicRepeatMode.none) {
												// TO DO: When this mode is selected, show it as such; don’t disable it.
												// As of iOS 16.2 developer beta 1, when using `UIMenu.ElementSize.small`, neither `UIMenu.Options.singleSelection` nor `UIMenuElement.State.on` visually selects any menu item.
												result.formUnion(.disabled)
											}
											return result
										}(),
										state: {
											guard let player = Self.player else {
												return .on // Default when disabled
											}
											return (
												player.repeatMode == MPMusicRepeatMode.none
												? .on
												: .off
											)
										}(),
										handler: { action in
											Self.player?.repeatMode = .none
										}
									)
									useMenuElements([action])
								}),
								
								UIDeferredMenuElement.uncached({ useMenuElements in
									let action = UIAction(
										title: LRString.repeatAll,
										image: UIImage(systemName: "repeat"),
										attributes: {
											var result: UIMenuElement.Attributes = []
											if (Self.player == nil) || (Self.player?.repeatMode == .all) {
												result.formUnion(.disabled)
											}
											return result
										}(),
										state: {
											guard let player = Self.player else {
												return .off
											}
											return (
												player.repeatMode == .all
												? .on
												: .off
											)
										}(),
										handler: { action in
											Self.player?.repeatMode = .all
										}
									)
									useMenuElements([action])
								}),
								
								UIDeferredMenuElement.uncached({ useMenuElements in
									let action = UIAction(
										title: LRString.repeat1,
										image: UIImage(systemName: "repeat.1"),
										attributes: {
											var result: UIMenuElement.Attributes = []
											if (Self.player == nil) || (Self.player?.repeatMode == .one) {
												result.formUnion(.disabled)
											}
											return result
										}(),
										state: {
											guard let player = Self.player else {
												return .off
											}
											return (
												player.repeatMode == .one
												? .on
												: .off
											)
										}(),
										handler: { action in
											Self.player?.repeatMode = .one
										}
									)
									useMenuElements([action])
								}),
							]
						),
					],
					
					[
						UIDeferredMenuElement.uncached({ useMenuElements in
							let action = UIAction(
								title: LRString.previous,
								image: UIImage(systemName: "backward.end.circle"),
								attributes: {
									var result: UIMenuElement.Attributes = [
										.keepsMenuPresented,
									]
									// TO DO: Disable this menu element when the player is playing the first track in the queue, or when that becomes true.
									if Self.player == nil {
										result.formUnion(.disabled)
									}
									return result
								}(),
								handler: { action in
									Self.player?.skipToPreviousItem()
								}
							)
							useMenuElements([action])
						}),
						
						UIDeferredMenuElement.uncached({ useMenuElements in
							let action = UIAction(
								title: LRString.restart,
								image: UIImage(systemName: "arrow.counterclockwise.circle"),
								attributes: {
									var result: UIMenuElement.Attributes = []
									if Self.player == nil {
										result.formUnion(.disabled)
									}
									return result
								}(),
								handler: { action in
									Self.player?.skipToBeginning()
								}
							)
							useMenuElements([action])
						}),
					],
				]
			)
		)
		return button
	}()
	
	private lazy var skipBackButton: UIBarButtonItem = {
		let button = UIBarButtonItem(
			title: LRString.skip10SecondsBackwards,
			image: UIImage(systemName: "gobackward.15"),
			primaryAction: UIAction { _ in
				Self.player?.currentPlaybackTime -= 15
			})
		button.accessibilityTraits.formUnion(.startsMediaSession)
		return button
	}()
	
	private lazy var playPauseButton = UIBarButtonItem()
	
	private lazy var skipForwardButton: UIBarButtonItem = {
		let button = UIBarButtonItem(
			title: LRString.skip10SecondsForward,
			image: UIImage(systemName: "goforward.15"),
			primaryAction: UIAction { _ in
				Self.player?.currentPlaybackTime += 15
			})
		button.accessibilityTraits.formUnion(.startsMediaSession)
		return button
	}()
	
	private lazy var nextButton: UIBarButtonItem = {
		let button = UIBarButtonItem(
			title: LRString.next,
			image: UIImage(systemName: "forward.end.circle"),
			primaryAction: UIAction { _ in
				Self.player?.skipToNextItem()
			})
		button.accessibilityTraits.formUnion(.startsMediaSession)
		return button
	}()
	
	var buttons_array: [UIBarButtonItem] {
		if Enabling.inAppPlayer {
			return [
				showConsoleButton,
				.flexibleSpace(),
				skipBackButton,
				.flexibleSpace(),
				playPauseButton,
				.flexibleSpace(),
				skipForwardButton,
				.flexibleSpace(),
				nextButton,
			]
		} else {
			return [
				moreButton,
				.flexibleSpace(),
				skipBackButton,
				.flexibleSpace(),
				playPauseButton,
				.flexibleSpace(),
				skipForwardButton,
				.flexibleSpace(),
				nextButton,
			]
		}
	}
	
	init(
		showConsoleAction: UIAction
	) {
		showConsoleButton = UIBarButtonItem(
			title: LRString.more,
			primaryAction: showConsoleAction)
		
		freshen()
		TapeDeck.shared.addReflector(weakly: self)
		
		NotificationCenter.default.addObserverOnce(
			self,
			selector: #selector(userChangedReelEmptiness),
			name: .userChangedReelEmptiness,
			object: nil)
	}
	@objc private func userChangedReelEmptiness() {
		freshen()
	}
	
//	private static let showConsoleButtonDefaultImage = UIImage(systemName: "line.3.horizontal.circle")!
	private static let showConsoleButtonDefaultImage = UIImage(systemName: "chevron.up.circle")!
	private static let more_button_default_image = UIImage(systemName: "ellipsis.circle")!
	private func freshen() {
		
		/*
		func freshen_more_button() {
			let new_image: UIImage
			defer {
				moreButton.image = new_image
			}
			guard let player = Self.player else {
				// Configure ellipsis icon
				new_image = Self.more_button_default_image
				return
			}
			new_image = {
				switch player.repeatMode {
				case .one:
					return UIImage(systemName: "repeat.1.circle.fill")!
				case .all:
					return UIImage(systemName: "repeat.circle.fill")!
				case
						.default,
						.none // TO DO: When the user first grants access to Music, Media Player incorrectly returns `.none`.
					:
					return Self.more_button_default_image
				@unknown default:
					return Self.more_button_default_image
				}
			}()
		}
		freshen_more_button()
		*/
		
		func configurePlayButton() {
			playPauseButton.title = LRString.play
			playPauseButton.primaryAction = UIAction(
				image: UIImage(systemName: "play.circle")
			) { _ in
				Self.player?.play()
			}
			playPauseButton.accessibilityTraits.formUnion(.startsMediaSession)
		}
		
		guard
			let player = Self.player,
			!(Enabling.inAppPlayer && Reel.mediaItems.isEmpty) // When enabling in-app player, when reel is empty, disable transport buttons.
		else {
			configurePlayButton()
			
			showConsoleButton.image = Self.showConsoleButtonDefaultImage
			
			// Enable or disable each button as appropriate
			buttons_array.forEach {
				$0.disableWithAccessibilityTrait()
			}
			moreButton.enableWithAccessibilityTrait()
			showConsoleButton.enableWithAccessibilityTrait()
			return
		}
		
		showConsoleButton.image = {
			switch player.repeatMode {
			case .one:
				return UIImage(systemName: "repeat.1.circle.fill")!
			case .all:
				return UIImage(systemName: "repeat.circle.fill")!
			case
					.default,
					.none
				:
				return Self.showConsoleButtonDefaultImage
			@unknown default:
				return Self.showConsoleButtonDefaultImage
			}
		}()
		
		if player.playbackState == .playing {
			// Configure “pause” button
			playPauseButton.title = LRString.pause
			playPauseButton.primaryAction = UIAction(
				image: UIImage(systemName: "pause.circle")
			) { _ in
				Self.player?.pause()
			}
			playPauseButton.accessibilityTraits.subtract(.startsMediaSession)
		} else {
			configurePlayButton()
		}
		
		// Enable or disable each button as appropriate
		buttons_array.forEach {
			$0.enableWithAccessibilityTrait()
		}
	}
}
extension MainToolbar: TapeDeckReflecting {
	func reflect_playback_mode() {
		freshen()
	}
	
	func reflect_now_playing_item() {
		freshen()
	}
}
