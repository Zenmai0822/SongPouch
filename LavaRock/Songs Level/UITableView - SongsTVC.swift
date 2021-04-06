//
//  UITableView - SongsTVC.swift
//  LavaRock
//
//  Created by h on 2020-08-30.
//

import UIKit
import MediaPlayer

extension SongsTVC {
	
	// MARK: - Cells
	
	final override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard MPMediaLibrary.authorizationStatus() == .authorized else {
			return UITableViewCell()
		}
		
		switch indexPath.row {
		case 0:
			return albumArtworkCell()
		case 1:
			return albumInfoCell()
		default:
			return songCell(forRowAt: indexPath)
		}
	}
	
	private func albumArtworkCell() -> UITableViewCell {
		// Get the data to put into the cell.
		guard let album = sectionOfLibraryItems.container as? Album else {
			return UITableViewCell()
		}
		let representativeItem = album.mpMediaItemCollection()?.representativeItem
		let cellImage = representativeItem?.artwork?.image(at: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
		
		// Make, configure, and return the cell.
		
		guard let albumArtworkCell = tableView.dequeueReusableCell(withIdentifier: "Album Artwork Cell") as? AlbumArtworkCell else {
			return UITableViewCell()
		}
		albumArtworkCell.artworkImageView.image = cellImage
		
		albumArtworkCell.accessibilityUserInputLabels = [""]
		
		return albumArtworkCell
	}
	
	private func albumInfoCell() -> UITableViewCell {
		// Get the data to put into the cell.
		guard let album = sectionOfLibraryItems.container as? Album else {
			return UITableViewCell()
		}
		let cellHeading = album.albumArtistFormattedOrPlaceholder()
		let cellSubtitle = album.releaseDateEstimateFormatted()
		
		// Make, configure, and return the cell.
		if let cellSubtitle = cellSubtitle {
			guard let albumInfoCell = tableView.dequeueReusableCell(withIdentifier: "Album Info Cell") as? AlbumInfoCell else {
				return UITableViewCell()
			}
			albumInfoCell.albumArtistLabel.text = cellHeading
			albumInfoCell.releaseDateLabel.text = cellSubtitle
			
			albumInfoCell.accessibilityUserInputLabels = [""]
			
			return albumInfoCell
			
		} else { // We couldn't determine the album's release date.
			guard let albumInfoCell = tableView.dequeueReusableCell(withIdentifier: "Album Info Cell Without Release Date") as? AlbumInfoCellWithoutReleaseDate else {
				return UITableViewCell()
			}
			albumInfoCell.albumArtistLabel.text = cellHeading
			
			albumInfoCell.accessibilityUserInputLabels = [""]
			
			return albumInfoCell
		}
	}
	
	private func songCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		// Get the data to put into the cell.
		guard let song = libraryItem(for: indexPath) as? Song else {
			return UITableViewCell()
		}
		let cellTitle = song.titleFormattedOrPlaceholder()
		let isNowPlayingSong = isItemNowPlaying(at: indexPath)
		let cellNowPlayingIndicator = PlayerControllerManager.nowPlayingIndicator(
			isItemNowPlaying: isNowPlayingSong)
		let cellTrackNumberText = song.trackNumberFormattedOrPlaceholder()
		
		// Make, configure, and return the cell.
		if
			let cellArtist = song.artistFormatted(),
			cellArtist != (sectionOfLibraryItems.container as? Album)?.albumArtistFormattedOrPlaceholder()
		{
			guard var cell = tableView.dequeueReusableCell(withIdentifier: "Cell with Different Artist", for: indexPath) as? SongCellWithDifferentArtist else {
				return UITableViewCell()
			}
			cell.artistLabel.text = cellArtist
			
			cell.titleLabel.text = cellTitle
			cell.applyNowPlayingIndicator(cellNowPlayingIndicator)
			cell.trackNumberLabel.text = cellTrackNumberText
			cell.trackNumberLabel.font = UIFont.bodyMonospacedNumbers
			
			cell.accessibilityUserInputLabels = [cellTitle]
			
			return cell
			
		} else { // The song's artist is not useful, or it's the same as the album artist.
			guard var cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? SongCell else { // As of some beta of iOS 14.0, UIListContentConfiguration.valueCell() doesn't gracefully accommodate multiple lines of text.
				return UITableViewCell()
			}
			
			cell.titleLabel.text = cellTitle
			cell.applyNowPlayingIndicator(cellNowPlayingIndicator)
			cell.trackNumberLabel.text = cellTrackNumberText
			cell.trackNumberLabel.font = UIFont.bodyMonospacedNumbers
			
			cell.accessibilityUserInputLabels = [cellTitle]
			
			return cell
		}
	}
	
	// MARK: - Selecting
	
	final override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if isEditing {
		} else {
			guard let song = libraryItem(for: indexPath) as? Song else { return }
			if let selectedCell = tableView.cellForRow(at: indexPath) {
				showSongActions(for: song, popoverAnchorView: selectedCell)
			}
			// This leaves the row selected while the action sheet is onscreen, which I prefer.
			// You must eventually deselect the row, and set isPresentingSongActions = false, in every possible branch from here.
		}
		
		super.tableView(tableView, didSelectRowAt: indexPath) // Includes refreshBarButtons() in editing mode.
	}
	
}
