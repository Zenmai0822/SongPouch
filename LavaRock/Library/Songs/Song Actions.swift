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
		
		guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
		
		let playRestOfAlbum = UIAlertAction(
			title: LocalizedString.playRestOfAlbum,
			style: .default
		) { _ in
			self.playAlbumStartingAt(selectedIndexPath)
			deselectSelectedSong()
		}
		// I want to silence VoiceOver after you choose “play now” actions, but `UIAlertAction.accessibilityTraits = .startsMediaSession` doesn’t do it.
		let appendRestOfAlbum: UIAlertAction = {
			let result = UIAlertAction(
				title: LocalizedString.queueRestOfAlbum,
				style: .default
			) { _ in
				self.appendAlbumStartingAt(selectedIndexPath)
				deselectSelectedSong()
			}
			if
				let selectedIndexPath = tableView.indexPathForSelectedRow,
				let lastSongInGroup = viewModel.group(forSection: selectedIndexPath.section).items.last,
				song == lastSongInGroup
			{
				result.isEnabled = false
			}
			return result
		}()
		
		let playSong = UIAlertAction(
			title: "Play Song", // L2DO
			style: .default
		) { _ in
			self.playSong(at: selectedIndexPath)
			deselectSelectedSong()
		}
		let prependSong = UIAlertAction(
			title: "Play Next", // L2DO
			style: .default
		) { _ in
			self.prependSong(at: selectedIndexPath)
			deselectSelectedSong()
		}
		let appendSong = UIAlertAction(
			title: Enabling.wholeAlbumButtons
			? "Play Last" // L2DO
			: LocalizedString.queueSong,
			style: .default
		) { _ in
			self.appendSong(at: selectedIndexPath)
			deselectSelectedSong()
		}
		
		let cancel = UIAlertAction.cancel { _ in
			deselectSelectedSong()
		}
		
		let actionSheet = UIAlertController(
			title: nil,
			message: nil,
			preferredStyle: .actionSheet)
		
		if Enabling.wholeAlbumButtons {
			actionSheet.addAction(playSong)
			actionSheet.addAction(prependSong)
			actionSheet.addAction(appendSong)
		} else {
			actionSheet.addAction(playRestOfAlbum)
			actionSheet.addAction(appendRestOfAlbum)
			actionSheet.addAction(appendSong)
		}
		actionSheet.addAction(cancel)
		
		actionSheet.popoverPresentationController?.sourceView = popoverAnchorView
		
		present(actionSheet, animated: true)
	}
	
	// MARK: Actions
	
	private func playAlbumStartingAt(_ indexPath: IndexPath) {
		guard let player = player else { return }
		
		if Enabling.playerScreen {
			SongQueue.set(
				songs: viewModel.itemsInGroup(startingAt: indexPath)
					.compactMap { $0 as? Song },
				thenApplyTo: player)
		} else {
			player.setQueue(with: viewModel.itemsInGroup(startingAt: indexPath)
				.compactMap { $0 as? Song })
		}
		
		// As of iOS 14.7 developer beta 1, you must set these after calling `setQueue`, not before, or they won’t actually apply.
		player.repeatMode = .none
		player.shuffleMode = .off
		
		player.play() // Calls `prepareToPlay` automatically
	}
	
	private func appendAlbumStartingAt(_ indexPath: IndexPath) {
		guard let player = player else { return }
		
		let chosenSongs = viewModel.itemsInGroup(startingAt: indexPath)
			.compactMap { $0 as? Song }
		
		if Enabling.playerScreen {
			SongQueue.append(
				songs: chosenSongs,
				thenApplyTo: player)
		} else {
			player.appendToQueue(chosenSongs)
		}
		
		player.repeatMode = .none
		
		// As of iOS 14.7 developer beta 1, you must do this in case the user force quit the built-in Music app recently.
		if player.playbackState != .playing {
			player.prepareToPlay()
		}
		
		if Enabling.playerScreen {
		} else {
			if
				let selectedSong = viewModel.itemNonNil(at: indexPath) as? Song,
				let selectedMetadata = selectedSong.metadatum()
			{
				let selectedTitle = selectedMetadata.titleOnDisk ?? SongMetadatumExtras.unknownTitlePlaceholder
				presentWillPlayLaterAlertIfShould(
					titleOfSelectedSong: selectedTitle,
					numberOfSongsEnqueued: chosenSongs.count)
			}
		}
	}
	
	private func playSong(at indexPath: IndexPath) {
		guard
			let selectedSong = viewModel.itemNonNil(at: indexPath) as? Song,
			let player = player
		else { return }
		
		player.setQueue(with: [selectedSong])
		
		player.repeatMode = .none
		player.shuffleMode = .off
		
		player.play()
	}
	
	private func prependSong(at indexPath: IndexPath) {
		guard
			let selectedSong = viewModel.itemNonNil(at: indexPath) as? Song,
			let selectedMediaItem = selectedSong.metadatum() as? MPMediaItem,
			let player = player
		else { return }
		
		player.repeatMode = .none
		
		player.prepend(
			MPMusicPlayerMediaItemQueueDescriptor(
				itemCollection: MPMediaItemCollection(
					items: [selectedMediaItem])))
	}
	
	private func appendSong(at indexPath: IndexPath) {
		guard
			let selectedSong = viewModel.itemNonNil(at: indexPath) as? Song,
			let player = player
		else { return }
		
		if Enabling.playerScreen {
			SongQueue.append(
				songs: [selectedSong],
				thenApplyTo: player)
		} else {
			player.appendToQueue([selectedSong])
		}
		
		player.repeatMode = .none
		
		if player.playbackState != .playing {
			player.prepareToPlay()
		}
		
		if Enabling.playerScreen {
		} else {
			presentWillPlayLaterAlertIfShould(
				titleOfSelectedSong: {
					let selectedMediaItem = selectedSong.metadatum() as? MPMediaItem
					return selectedMediaItem?.title ?? SongMetadatumExtras.unknownTitlePlaceholder
				}(),
				numberOfSongsEnqueued: 1)
		}
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
			style: .default
		) { _ in
			self.willPlayLaterAlertIsPresented = false
		}
		
		alert.addAction(dontShowAgainAction)
		alert.addAction(okAction)
		alert.preferredAction = okAction
		
		willPlayLaterAlertIsPresented = true
		present(alert, animated: true)
	}
}
