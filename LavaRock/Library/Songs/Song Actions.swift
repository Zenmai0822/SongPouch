//
//  Song Actions.swift
//  LavaRock
//
//  Created by h on 2020-09-14.
//

import UIKit
import MediaPlayer
import OSLog

extension SongsTVC {
	// MARK: Presenting
	
	final func showSongActions(
		for song: Song,
		popoverAnchorView: UIView
	) {
		// Keep the row for the selected `Song` selected until we complete or cancel an action for it. That means we also need to deselect it in every possible branch from here. Use this function for convenience.
		func deselectSelectedSong() {
			tableView.deselectAllRows(animated: true)
		}
		
		let playRestOfAlbumAction = UIAlertAction(
			title: LocalizedString.playRestOfAlbum,
			style: .default
		) { _ in
			self.playAlbumStartingAtSelectedSong()
			deselectSelectedSong()
		}
//		playAlbumStartingAtSelectedSongAction.accessibilityTraits = .startsMediaSession // I want to silence VoiceOver after you choose this action, but this line of code doesn’t do it.
		let enqueueRestOfAlbumAction = UIAlertAction(
			title: LocalizedString.queueRestOfAlbum,
			style: .default
		) { _ in
			self.enqueueAlbumStartingAtSelectedSong()
			deselectSelectedSong()
		}
		let enqueueSongAction = UIAlertAction(
			title: LocalizedString.queueSong,
			style: .default
		) { _ in
			self.enqueueSelectedSong()
			deselectSelectedSong()
		}
		let cancelAction = UIAlertAction.cancel { _ in
			deselectSelectedSong()
		}
		
		// Disable the actions that we shouldn’t offer for the last `Song` in the section.
		if
			let selectedIndexPath = tableView.indexPathForSelectedRow,
			let lastSongInGroup = viewModel.group(forSection: selectedIndexPath.section).items.last,
			song == lastSongInGroup
		{
			enqueueRestOfAlbumAction.isEnabled = false
		}
		
		let actionSheet = UIAlertController(
			title: nil,
			message: nil,
			preferredStyle: .actionSheet)
		
		actionSheet.addAction(playRestOfAlbumAction)
		actionSheet.addAction(enqueueRestOfAlbumAction)
		actionSheet.addAction(enqueueSongAction)
		actionSheet.addAction(cancelAction)
		
		actionSheet.popoverPresentationController?.sourceView = popoverAnchorView
		
		present(actionSheet, animated: true)
	}
	
	// MARK: Actions
	
	private func playAlbumStartingAtSelectedSong() {
		guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
		
		let chosenSongs = viewModel.itemsInGroup(startingAt: selectedIndexPath)
		os_signpost(.begin, log: .songsView, name: "Get chosen MPMediaItems")
		let chosenMediaItems = chosenSongs.compactMap {
			($0 as? Song)?.songFile() as? MPMediaItem
		}
		os_signpost(.end, log: .songsView, name: "Get chosen MPMediaItems")
		let mediaItemCollection = MPMediaItemCollection(items: chosenMediaItems)
		
		player?.setQueue(with: mediaItemCollection)
		
		// As of iOS 14.7 developer beta 1, you must set these after calling `setQueue`, not before, or they won’t actually apply.
		player?.repeatMode = .none
		player?.shuffleMode = .off
		
		player?.play() // Calls `prepareToPlay` automatically
	}
	
	private func enqueueAlbumStartingAtSelectedSong() {
		guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
		
		let chosenSongs = viewModel.itemsInGroup(startingAt: selectedIndexPath)
		os_signpost(.begin, log: .songsView, name: "Get chosen MPMediaItems")
		let chosenMediaItems = chosenSongs.compactMap {
			($0 as? Song)?.songFile() as? MPMediaItem
		}
		os_signpost(.end, log: .songsView, name: "Get chosen MPMediaItems")
		let mediaItemCollection = MPMediaItemCollection(items: chosenMediaItems)
		
		let queueDescriptor = MPMusicPlayerMediaItemQueueDescriptor(itemCollection: mediaItemCollection)
		player?.append(queueDescriptor)
		
		player?.repeatMode = .none
		player?.shuffleMode = .off
		
		// As of iOS 14.7 developer beta 1, you must do this in case the user force quit the built-in Music app recently.
		if player?.playbackState != .playing {
			player?.prepareToPlay()
		}
		
		if
			let selectedSong = viewModel.itemNonNil(at: selectedIndexPath) as? Song,
			let selectedSongFile = selectedSong.songFile()
		{
			let selectedTitle = selectedSongFile.titleOnDisk ?? SongFileExtras.unknownTitlePlaceholder
			presentWillPlayLaterAlertIfShould(
				titleOfSelectedSong: selectedTitle,
				numberOfSongsEnqueued: chosenMediaItems.count)
		}
	}
	
	private func enqueueSelectedSong() {
		guard
			let selectedIndexPath = tableView.indexPathForSelectedRow,
			let selectedSong = viewModel.itemNonNil(at: selectedIndexPath) as? Song,
			let selectedMediaItem = selectedSong.songFile() as? MPMediaItem
		else { return }
		let mediaItemCollection = MPMediaItemCollection(items: [selectedMediaItem])
		
		let queueDescriptor = MPMusicPlayerMediaItemQueueDescriptor(itemCollection: mediaItemCollection)
		player?.append(queueDescriptor)
		
		player?.repeatMode = .none
		player?.shuffleMode = .off
		
		// As of iOS 14.7 developer beta 1, you must do this in case the user force quit the built-in Music app recently.
		if player?.playbackState != .playing {
			player?.prepareToPlay()
		}
		
		let selectedTitle = selectedMediaItem.title ?? SongFileExtras.unknownTitlePlaceholder
		presentWillPlayLaterAlertIfShould(
			titleOfSelectedSong: selectedTitle,
			numberOfSongsEnqueued: 1)
	}
	
	// MARK: Explaining Enqueue Actions
	
	private func presentWillPlayLaterAlertIfShould(
		titleOfSelectedSong: String,
		numberOfSongsEnqueued: Int
	) {
		let defaults = UserDefaults.standard
		let defaultsKey = LRUserDefaultsKey.shouldExplainQueueAction.rawValue
		
		defaults.register(defaults: [defaultsKey: true])
		let shouldShowExplanation = defaults.bool(forKey: defaultsKey)
		guard shouldShowExplanation else { return }
		
		let alertTitle: String
		switch numberOfSongsEnqueued {
		case 1:
			alertTitle = String.localizedStringWithFormat(
				LocalizedString.format_didEnqueueOneSongAlertTitle,
				titleOfSelectedSong)
		default:
			alertTitle = String.localizedStringWithFormat(
				LocalizedString.format_didEnqueueMultipleSongsAlertTitle,
				titleOfSelectedSong, numberOfSongsEnqueued - 1)
		}
		let alertMessage = LocalizedString.didEnqueueSongsAlertMessage
		
		let alert = UIAlertController(
			title: alertTitle,
			message: alertMessage,
			preferredStyle: .alert)
		let dontShowAgainAction = UIAlertAction(
			title: LocalizedString.dontShowAgain,
			style: .default
		) { _ in
			self.willPlayLaterAlertIsPresented = false
			defaults.set(
				false,
				forKey: defaultsKey)
		}
		let okAction = UIAlertAction(
			title: LocalizedString.ok,
			style: .default,
			handler: { _ in
				self.willPlayLaterAlertIsPresented = false
			})
		
		alert.addAction(dontShowAgainAction)
		alert.addAction(okAction)
		alert.preferredAction = okAction
		
		willPlayLaterAlertIsPresented = true
		present(alert, animated: true)
	}
}
