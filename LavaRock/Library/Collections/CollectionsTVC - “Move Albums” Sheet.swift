//
//  CollectionsTVC - “Move Albums” Sheet.swift
//  LavaRock
//
//  Created by h on 2020-08-23.
//

import UIKit
import CoreData
import MediaPlayer

extension CollectionsTVC {
	
	final func createAndConfirm() {
		guard
			let collectionsViewModel = viewModel as? CollectionsViewModel,
			case let .movingAlbums(clipboard) = purpose,
			!clipboard.didAlreadyCreate // Without this, if you're fast, you can finish creating a new Collection by tapping "Save" in the dialog, and then tap "New Collection" to bring up another dialog before we enter the first Collection you made.
				// You must reset didAlreadyCreate = false both during reverting and if we exit the empty new Collection.
		else { return }
		
		clipboard.didAlreadyCreate = true
		
		let smartTitle: String? = {
			let albumsBeingMoved = clipboard.idsOfAlbumsBeingMoved.compactMap {
				collectionsViewModel.context.object(with: $0) as? Album
			}
			return Self.smartCollectionTitle(moving: albumsBeingMoved)
		}()
		create(smartTitle: smartTitle) {
			self.confirmCreate(smartTitle: smartTitle)
		}
	}
	
	private static func smartCollectionTitle(
		moving albumsOutOfOrder: [Album]
	) -> String? {
		guard let someAlbum = albumsOutOfOrder.first else {
			return nil
		}
		let otherAlbums = albumsOutOfOrder.dropFirst()
		// Don't query for all the album artists upfront, because that's slow.
		
		let existingTitles: Set<String>? = {
			guard let context = someAlbum.managedObjectContext else {
				return nil
			}
			let allCollections = Collection.allFetched(ordered: false, via: context)
			return Set(allCollections.compactMap { $0.title })
		}()
		
		// Check whether the album artists of the albums we're moving are all identical.
	albumArtistIdentical: do {
		let someAlbumArtist = someAlbum.albumArtistFormattedOrPlaceholder()
		
		if
			let existingTitles = existingTitles,
			existingTitles.contains(someAlbumArtist)
		{
			break albumArtistIdentical
		}
		
		if otherAlbums.allSatisfy({
			$0.albumArtistFormattedOrPlaceholder() == someAlbumArtist
		}) {
			return someAlbumArtist
		}
	}
		
		// Check whether the album artists of the albums we're moving all start with the same thing.
		/*
	albumArtistCommonPrefix: do {
		let commonPrefixTrimmed = albumsOutOfOrder.commonPrefixLazilyGeneratingStringsToCompare {
			$0.albumArtistFormattedOrPlaceholder()
		}.trimmingWhitespaceAtEnd()
		
		if
			let existingTitles = existingTitles,
			existingTitles.contains(commonPrefixTrimmed)
		{
			break albumArtistCommonPrefix
		}
		
		// TO DO: Internationalize
		let commonPrefixLength = commonPrefixTrimmed.count
		let commonPrefixTrimmedIsAtWordBoundary = albumsOutOfOrder.allSatisfy {
			let albumArtist = $0.albumArtistFormattedOrPlaceholder()
			return albumArtist.endsOrHasWhitespaceAfter(dropFirstCount: commonPrefixLength)
		}
		if commonPrefixTrimmedIsAtWordBoundary {
			return commonPrefixTrimmed
		}
	}
		*/
		
		// Otherwise, give up.
		return nil
	}
	
	private func create(
		smartTitle: String?,
		completion: (() -> Void)?
	) {
		let collectionsViewModel = viewModel as! CollectionsViewModel
		
		let title = smartTitle ?? (FeatureFlag.multicollection ? LocalizedString.newSectionDefaultTitle : LocalizedString.newCollectionDefaultTitle)
		let (newViewModel, indexPathOfNewCollection) = collectionsViewModel.updatedAfterCreating(title: title)
		
		tableView.performBatchUpdates {
			tableView.scrollToRow(
				at: indexPathOfNewCollection,
				at: .none,
				animated: true)
		} completion: { _ in
			self.setViewModelAndMoveRows(newViewModel)
			completion?()
		}
	}
	
	private func confirmCreate(smartTitle: String?) {
		let dialog = UIAlertController.forEditingCollectionTitle(
			alertTitle: FeatureFlag.multicollection ? LocalizedString.newSectionAlertTitle : LocalizedString.newCollectionAlertTitle,
			textFieldText: smartTitle,
			cancelHandler: revertCreate,
			saveHandler: { textFieldText in
				self.renameAndOpenCreated(proposedTitle: textFieldText)
			}
		)
		present(dialog, animated: true)
	}
	
	final func revertCreate() {
		guard
			case let .movingAlbums(clipboard) = purpose,
			let collectionsViewModel = viewModel as? CollectionsViewModel
		else { return }
		
		clipboard.didAlreadyCreate = false
		
		let newViewModel = collectionsViewModel.updatedAfterDeletingNewCollection()
		setViewModelAndMoveRows(newViewModel)
	}
	
	private func renameAndOpenCreated(proposedTitle: String?) {
		guard let collectionsViewModel = viewModel as? CollectionsViewModel else { return }
		
		let indexPath = collectionsViewModel.indexPathOfNewCollection
		
		let didChangeTitle = collectionsViewModel.renameAndReturnDidChangeTitle(
			at: indexPath,
			proposedTitle: proposedTitle)
		
		tableView.performBatchUpdates {
			if didChangeTitle {
				tableView.reloadRows(at: [indexPath], with: .fade)
			}
		} completion: { _ in
			self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
			self.performSegue(withIdentifier: "Open Collection", sender: self)
		}
	}
	
}
