//
//  Songs - Views.swift
//  LavaRock
//
//  Created by h on 2020-07-10.
//

import UIKit
import MediaPlayer
import SwiftUI
import OSLog

// The cell in the storyboard is completely default except for the reuse identifier and custom class.
final class CoverArtCell: UITableViewCell {
	var albumRepresentative: SongMetadatum? = nil
	
	func configureArtwork(
		maxHeight: CGFloat
	) {
		os_signpost(.begin, log: .songsView, name: "Configure cover art")
		contentConfiguration = UIHostingConfiguration {
			CoverArtView(
				albumRepresentative: albumRepresentative, // TO DO: Redraw when artwork changes
				maxHeight: maxHeight)
			.alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
				viewDimensions[.leading]
			}
			.alignmentGuide(.listRowSeparatorTrailing) { viewDimensions in
				viewDimensions[.trailing]
			}
		}
		.margins(.all, .zero)
		os_signpost(.end, log: .songsView, name: "Configure cover art")
	}
}

final class ExpandedTargetButton: UIButton {
	override func point(
		inside point: CGPoint,
		with event: UIEvent?
	) -> Bool {
		let tappableWidth = max(bounds.width, 44)
		let tappableHeight = max(bounds.height, 55)
		let tappableRect = CGRect(
			x: bounds.midX - tappableWidth/2,
			y: bounds.midY - tappableHeight/2,
			width: tappableWidth,
			height: tappableHeight)
		return tappableRect.contains(point)
	}
}

final class SongCell: UITableViewCell {
	private static let usesSwiftUI__ = 10 == 1
	
	// `AvatarDisplaying__`
	@IBOutlet var spacerSpeakerImageView: UIImageView!
	@IBOutlet var speakerImageView: UIImageView!
	
	private var rowContentAccessibilityLabel__: String? = nil
	
	@IBOutlet private var textStack: UIStackView!
	@IBOutlet private var titleLabel: UILabel!
	@IBOutlet private var artistLabel: UILabel!
	@IBOutlet private var spacerNumberLabel: UILabel!
	@IBOutlet private var numberLabel: UILabel!
	@IBOutlet private var dotDotDotButton: ExpandedTargetButton!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		selectedBackgroundView_add_tint()
		
		backgroundColor_set_to_clear()
		
		guard !Self.usesSwiftUI__ else { return }
		
		spacerNumberLabel.font = .monospacedDigitSystemFont(forTextStyle: .body)
		numberLabel.font = spacerNumberLabel.font
		
		dotDotDotButton.maximumContentSizeCategory = .extraExtraExtraLarge
		
		accessibilityTraits.formUnion(.button)
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
		freshenDotDotDotButton()
	}
	
	func configureWith(
		song: Song,
		albumRepresentative representative: SongMetadatum?,
		spacerTrackNumberText: String?,
		songsTVC: Weak<SongsTVC>
	) {
		let metadatum = song.metadatum() // Can be `nil` if the user recently deleted the `SongMetadatum` from their library
		
		let trackDisplay: String = {
			let result: String? = {
				guard
					let representative = representative,
					let metadatum = metadatum
				else {
					// Metadata not available
					return nil
				}
				if representative.shouldShowDiscNumber {
					// Disc and track number
					return metadatum.discAndTrackNumberFormatted()
				} else {
					// Track number only, which might be blank
					return metadatum.trackNumberFormattedOptional()
				}
			}()
			return result ?? "‒" // Figure dash
		}()
		let song_title: String? = metadatum?.titleOnDisk
		let artistDisplayOptional: String? = {
			let albumArtistOptional = representative?.albumArtistOnDisk
			if
				let songArtist = metadatum?.artistOnDisk,
				songArtist != albumArtistOptional
			{
				return songArtist
			} else {
				return nil
			}
		}()
		
		if Self.usesSwiftUI__ {
			
			contentConfiguration = UIHostingConfiguration {
				SongRow(
					song: song,
					trackDisplay: trackDisplay,
					song_title: song_title,
					artist_if_different_from_album_artist: artistDisplayOptional
				)
				.alignmentGuide(.listRowSeparatorTrailing) { viewDimensions in
					viewDimensions[.trailing]
				}
			}
			
		} else {
			
			spacerNumberLabel.text = spacerTrackNumberText
			numberLabel.text = trackDisplay
			titleLabel.text = { () -> String in
				song_title ?? SongMetadatumPlaceholder.unknownTitle
			}()
			artistLabel.text = artistDisplayOptional
			
			if artistLabel.text == nil {
				textStack.spacing = 0
			} else {
				textStack.spacing = 4
			}
			
			rowContentAccessibilityLabel__ = [
				numberLabel.text,
				titleLabel.text,
				artistLabel.text,
			].compactedAndFormattedAsNarrowList()
			indicateAvatarStatus__(
				song.avatarStatus()
			)
			
			freshenDotDotDotButton()
			
			accessibilityUserInputLabels = [
				song_title, // Excludes the “unknown title” placeholder, which is currently a dash.
			].compacted()
			
		}
		
		// Set menu, and require creating that menu
		let menu: UIMenu?
		defer {
			dotDotDotButton.menu = menu
		}
		
		guard let mediaItem = song.mpMediaItem() else {
			menu = nil
			return
		}
		
		// Create menu elements
		
		// For actions that start playback:
		// `MPMusicPlayerController.play` might need to fade out other currently-playing audio.
		// That blocks the main thread, so wait until the menu dismisses itself before calling it; for example, by doing the following asynchronously.
		// The UI will still freeze, but at least the menu won’t be onscreen while it happens.
		
		// Play next
		
		// Play song next
		let playSongNext =
		UIDeferredMenuElement.uncached({ useMenuElements in
			let action = UIAction(
				title: LRString.insertSong,
				image: UIImage(systemName: "text.line.first.and.arrowtriangle.forward")
			) { _ in
				TapeDeck.shared.player?.playNext([mediaItem])
			}
			action.attributes = (
				Reel.allows_Play_Next()
				? []
				: .disabled
			)
			useMenuElements([action])
		})
		
		// Play song and below next
		let playSongAndBelowNext =
		UIDeferredMenuElement.uncached({ useMenuElements in
			let thisMediaItemAndBelow = songsTVC.referencee?.mediaItemsInFirstGroup(startingAt: mediaItem) ?? []
			let action = UIAction(
				title: LRString.insertSongAndBelow,
				image: UIImage(systemName: "text.line.first.and.arrowtriangle.forward")
			) { _ in
				TapeDeck.shared.player?.playNext(thisMediaItemAndBelow)
			}
			action.attributes = (
				Reel.allows_Play_Next() && thisMediaItemAndBelow.count >= 2
				? []
				: .disabled
			)
			useMenuElements([action])
		})
		
		// Play last
		
		// Play song last
		let playSongLast =
		UIDeferredMenuElement.uncached({ useMenuElements in
			let action = UIAction(
				title: LRString.queueSong,
				image: UIImage(systemName: "text.line.last.and.arrowtriangle.forward")
			) { _ in
				TapeDeck.shared.player?.playLast([mediaItem])
			}
			useMenuElements([action])
		})
		
		// Play song and below last
		let playSongAndBelowLast =
		UIDeferredMenuElement.uncached({ useMenuElements in
			let thisMediaItemAndBelow = songsTVC.referencee?.mediaItemsInFirstGroup(startingAt: mediaItem) ?? []
			let action = UIAction(
				title: LRString.queueSongAndBelow,
				image: UIImage(systemName: "text.line.last.and.arrowtriangle.forward")
			) { _ in
				TapeDeck.shared.player?.playLast(thisMediaItemAndBelow)
			}
			action.attributes = (
				thisMediaItemAndBelow.count >= 2
				? []
				: .disabled
			)
			useMenuElements([action])
		})
		
		// —
		
		// Create menu
		menu = UIMenu(
			title: "",
			presentsUpward: false,
			menuElementGroups: [
				[
					playSongAndBelowNext,
					playSongNext,
				],
				[
					playSongAndBelowLast,
					playSongLast,
				],
			]
		)
	}
	
	private func freshenDotDotDotButton() {
		dotDotDotButton.isEnabled = !isEditing
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		guard !Self.usesSwiftUI__ else { return }
		
		separatorInset.left = 0
		+ contentView.frame.minX // Cell’s leading edge → content view’s leading edge
		+ textStack.frame.minX // Content view’s leading edge → text stack’s leading edge
		separatorInset.right = directionalLayoutMargins.trailing
	}
}
extension SongCell: AvatarDisplaying__ {
	func indicateAvatarStatus__(
		_ avatarStatus: AvatarStatus
	) {
		guard !Self.usesSwiftUI__ else { return }
		
		spacerSpeakerImageView.maximumContentSizeCategory = .extraExtraExtraLarge
		speakerImageView.maximumContentSizeCategory = spacerSpeakerImageView.maximumContentSizeCategory
		
		spacerSpeakerImageView.image = UIImage(systemName: Avatar.preference.playingSFSymbolName)
		
		speakerImageView.image = avatarStatus.uiImage
		
		accessibilityLabel = [
			avatarStatus.axLabel,
			rowContentAccessibilityLabel__,
		].compactedAndFormattedAsNarrowList()
	}
}
