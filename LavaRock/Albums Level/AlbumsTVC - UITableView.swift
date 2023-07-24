//
//  AlbumsTVC - UITableView.swift
//  LavaRock
//
//  Created by h on 2020-08-30.
//

import UIKit
import SwiftUI

extension AlbumsTVC {
	// MARK: - Numbers
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if viewModel.isEmpty() {
			// Don’t call `dequeueReusableCell` here to create the placeholder view as needed, because it can cause an infinite loop.
			tableView.backgroundView = noItemsBackgroundView
		} else {
			tableView.backgroundView = nil
		}
		
		return viewModel.groups.count
	}
	
	override func tableView(
		_ tableView: UITableView,
		numberOfRowsInSection section: Int
	) -> Int {
		return (viewModel as! AlbumsViewModel).numberOfRows()
	}
	
	// MARK: - Cells
	
	override func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		guard let albumsViewModel = viewModel as? AlbumsViewModel else { return UITableViewCell() }
		
		switch purpose {
			case .previewingCombine:
				break
			case .organizingAlbums:
				break
			case .movingAlbums:
				let rowCase = albumsViewModel.rowCase(for: indexPath)
				switch rowCase {
					case .prerow(let prerow):
						switch prerow {
							case .moveHere:
								// The cell in the storyboard is completely default except for the reuse identifier.
								let cell = tableView.dequeueReusableCell(
									withIdentifier: "Move Here",
									for: indexPath)
								cell.contentConfiguration = UIHostingConfiguration {
									HStack {
										Text(LRString.moveHere)
											.foregroundStyle(Color.accentColor)
											.bold()
										Spacer()
									}
									.accessibilityAddTraits(.isButton)
									.alignmentGuide(.listRowSeparatorTrailing) { viewDimensions in
										viewDimensions[.trailing]
									}
								}
								return cell
						}
					case .album:
						break
				}
			case .browsing:
				break
		}
		
		guard let cell = tableView.dequeueReusableCell(
			withIdentifier: "Album",
			for: indexPath) as? AlbumCell
		else { return UITableViewCell() }
		let album = albumsViewModel.albumNonNil(at: indexPath)
		cell.configure(
			with: album,
			mode: {
				switch purpose {
					case .previewingCombine:
						return .modalTinted
					case .organizingAlbums(let clipboard):
						if clipboard.idsOfSubjectedAlbums.contains(album.objectID) {
							return .modalTinted
						} else {
							return .modal
						}
					case .movingAlbums(let clipboard):
						if clipboard.idsOfAlbumsBeingMovedAsSet.contains(album.objectID) {
							return .modalTinted
						} else {
							return .modal
						}
					case .browsing:
						return .normal
				}
			}()
		)
		return cell
	}
	
	// MARK: - Selecting
	
	override func tableView(
		_ tableView: UITableView,
		shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath
	) -> Bool {
		switch purpose {
			case .previewingCombine:
				return false
			case .organizingAlbums:
				return false
			case .movingAlbums:
				return false
			case .browsing:
				return super.tableView(
					tableView,
					shouldBeginMultipleSelectionInteractionAt: indexPath)
		}
	}
	
	override func tableView(
		_ tableView: UITableView,
		willSelectRowAt indexPath: IndexPath
	) -> IndexPath? {
		switch purpose {
			case .previewingCombine:
				break
			case .organizingAlbums:
				break
			case .movingAlbums:
				guard let albumsViewModel = viewModel as? AlbumsViewModel else {
					return nil
				}
				let rowCase = albumsViewModel.rowCase(for: indexPath)
				switch rowCase {
					case .prerow(let prerow):
						switch prerow {
							case .moveHere:
								return indexPath
						}
					case .album:
						break
				}
			case .browsing:
				break
		}
		
		return super.tableView(tableView, willSelectRowAt: indexPath)
	}
	
	override func tableView(
		_ tableView: UITableView,
		didSelectRowAt indexPath: IndexPath
	) {
		switch purpose {
			case .previewingCombine:
				break
			case .organizingAlbums:
				break
			case .movingAlbums:
				guard let albumsViewModel = viewModel as? AlbumsViewModel else { return }
				let rowCase = albumsViewModel.rowCase(for: indexPath)
				switch rowCase {
					case .prerow(let prerow):
						switch prerow {
							case .moveHere:
								moveHere(to: indexPath)
								return
						}
					case .album:
						break
				}
			case .browsing:
				break
		}
		
		super.tableView(tableView, didSelectRowAt: indexPath)
	}
}
