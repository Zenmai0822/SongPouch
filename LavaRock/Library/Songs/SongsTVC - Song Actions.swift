//
//  Song Actions.swift
//  LavaRock
//
//  Created by h on 2020-09-14.
//

import UIKit
import MediaPlayer

extension SongsTVC {
	final func showSongActions(
		for song: Song,
		popoverAnchorView: UIView
	) {
		// Keep the row for the selected `Song` selected until we complete or cancel an action for it. That means we also need to deselect it in every possible branch from here. Use this function for convenience.
		func deselectSelectedSong() {
			tableView.deselectAllRows(animated: true)
		}
		
		guard
			let selectedIndexPath = tableView.indexPathForSelectedRow,
			let selectedMediaItem = (viewModel.itemNonNil(at: selectedIndexPath) as? Song)?.mpMediaItem(),
			let player = player
		else { return }
		
		// TO DO: Mock `selectedMediaItem` in the Simulator.
		
		let selectedMediaItemAndBelow: [MPMediaItem]
		= viewModel
			.itemsInGroup(startingAt: selectedIndexPath)
			.compactMap { ($0 as? Song)?.mpMediaItem() }
		let firstSongTitle: String = {
			selectedMediaItem.titleOnDisk ?? SongMetadatumPlaceholder.unknownTitle
		}()
		
		// Create action sheet
		
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		actionSheet.popoverPresentationController?.sourceView = popoverAnchorView
		
		// Add title
		
		actionSheet.title = {
			if selectedMediaItemAndBelow.count == 1 {
				return String.localizedStringWithFormat(
					LocalizedString.format_quoted,
					firstSongTitle)
			} else {
				return String.localizedStringWithFormat(
					LocalizedString.format_title_songTitleAndXMoreSongs,
					firstSongTitle,
					selectedMediaItemAndBelow.count - 1)
			}
		}()
		
		// Add actions
		
		// Play
		actionSheet.addAction(
			UIAlertAction(title: LocalizedString.play, style: .default) { _ in
				player.playNow(selectedMediaItemAndBelow)
				deselectSelectedSong()
			}
			// I want to silence VoiceOver after you choose “play now” actions, but `UIAlertAction.accessibilityTraits = .startsMediaSession` doesn’t do it.)
		)
		
		// Play next
		actionSheet.addAction(
			UIAlertAction(title: LocalizedString.playNext, style: .default) { _ in
				player.playNext(selectedMediaItemAndBelow)
				self.presentOpenMusicAlertIfNeeded(
					willPlayNextAsOpposedToLast: true,
					havingVerbedSongCount: selectedMediaItemAndBelow.count,
					firstSongTitle: firstSongTitle)
				deselectSelectedSong()
			}
		)
		
		// Play last
		let playLastAction = UIAlertAction(title: LocalizedString.playLast, style: .default) { _ in
			player.playLast(selectedMediaItemAndBelow)
			self.presentOpenMusicAlertIfNeeded(
				willPlayNextAsOpposedToLast: false,
				havingVerbedSongCount: selectedMediaItemAndBelow.count,
				firstSongTitle: firstSongTitle)
			deselectSelectedSong()
		}
		// Disable if appropriate
		playLastAction.isEnabled = Reel.shouldEnablePlayLast()
		actionSheet.addAction(playLastAction)
		
		// Cancel
		actionSheet.addAction(
			UIAlertAction.cancelWithHandler { _ in
				deselectSelectedSong()
			}
		)
		
		// Present action sheet
		
		present(actionSheet, animated: true)
	}
}
