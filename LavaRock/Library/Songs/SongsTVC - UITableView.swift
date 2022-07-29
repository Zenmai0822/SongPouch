//
//  SongsTVC - UITableView.swift
//  LavaRock
//
//  Created by h on 2020-08-30.
//

import UIKit

extension SongsTVC {
	// MARK: - Numbers
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		setOrRemoveNoItemsBackground()
		
		return viewModel.numberOfPresections.value + viewModel.groups.count
	}
	
	override func tableView(
		_ tableView: UITableView,
		numberOfRowsInSection section: Int
	) -> Int {
		return viewModel.numberOfRows(for: Section_I(section))
	}
	
	// MARK: - Headers
	
	override func tableView(
		_ tableView: UITableView,
		titleForHeaderInSection section: Int
	) -> String? {
		if Enabling.multialbum {
			return (viewModel as? SongsViewModel)?
				.album(for: Section_I(section))
				.representativeTitleFormattedOrPlaceholder()
		} else {
			return nil
		}
	}
	
	// MARK: - Cells
	
	override func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		guard let songsViewModel = viewModel as? SongsViewModel
		else {
			return UITableViewCell()
		}
		let album = songsViewModel.album(for: indexPath.section_i)
		
		let rowCase = songsViewModel.rowCase(for: indexPath)
		switch rowCase {
		case .prerow(let prerow):
			switch prerow {
			case .coverArt:
				guard let cell = tableView.dequeueReusableCell(
					withIdentifier: "Cover Art",
					for: indexPath) as? CoverArtCell
				else { return UITableViewCell() }
				
				cell.configure(with: album)
				
				return cell
				
			case .albumInfo:
				guard let cell = tableView.dequeueReusableCell(
					withIdentifier: "Album Info",
					for: indexPath) as? AlbumInfoCell
				else { return UITableViewCell() }
				
				cell.configure(with: album)
				
				return cell
			}
		case .song:
			break
		}
		
		guard let cell = tableView.dequeueReusableCell(
			withIdentifier: "Song",
			for: indexPath) as? SongCell
		else { return UITableViewCell() }
		
		cell.configureWith(
			song: songsViewModel.songNonNil(at: indexPath),
			albumRepresentative: {
				let album = songsViewModel.album(for: indexPath.section_i)
				return album.representativeSongMetadatum()
			}(),
			spacerTrackNumberText: (songsViewModel.group(for: indexPath.section_i) as? SongsGroup)?.spacerTrackNumberText
		)
		
		return cell
	}
	
	// MARK: - Selecting
	
	override func tableView(
		_ tableView: UITableView,
		didSelectRowAt indexPath: IndexPath
	) {
		if isEditing {
		} else {
			if
				let song = viewModel.itemNonNil(at: indexPath) as? Song,
				let selectedCell = tableView.cellForRow(at: indexPath)
			{
				showSongActions(for: song, popoverAnchorView: selectedCell)
				// This leaves the row selected while the action sheet is onscreen, which I prefer.
				// You must eventually deselect the row in every possible branch from here.
			}
		}
		
		super.tableView(tableView, didSelectRowAt: indexPath)
	}
}
