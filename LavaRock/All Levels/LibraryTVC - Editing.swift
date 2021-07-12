//
//  LibraryTVC - Editing.swift
//  LavaRock
//
//  Created by h on 2020-08-23.
//

import UIKit
import CoreData

extension LibraryTVC {
	
	final override func setEditing(
		_ editing: Bool,
		animated: Bool
	) {
		if isEditing {
			managedObjectContext.tryToSave()
		}
		
		super.setEditing(
			editing,
			animated: animated)
		
		setBarButtons(animated: animated)
		
		tableView.performBatchUpdates(nil) // Makes the cells resize themselves (expand if text has wrapped around to new lines; shrink if text has unwrapped into fewer lines). Otherwise, they'll stay the same size until they reload some other time, like after you edit them or scroll them offscreen and back onscreen.
		// During WWDC 2021, I did a lab in UIKit where the Apple engineer said that this is the best practice for doing this.
	}
	
	// MARK: - Allowing
	
	// You should only be allowed to sort contiguous items within the same SectionOfLibraryItems.
	final func allowsSort() -> Bool {
		guard !sectionOfLibraryItems.isEmpty() else {
			return false
		}
		
		if tableView.indexPathsForSelectedRowsNonNil.isEmpty {
			return true // Multisection: Only if we have exactly 1 SectionOfLibraryItems.
		} else {
			return tableView.indexPathsForSelectedRowsNonNil.isContiguousWithinSameSection()
		}
	}
	
	final func allowsMoveToTopOrBottom() -> Bool {
		return allowsFloat()
	}
	
	final func allowsFloat() -> Bool {
		guard !sectionOfLibraryItems.isEmpty() else {
			return false
		}
		
		if tableView.indexPathsForSelectedRowsNonNil.isEmpty {
			return false
		} else {
			return tableView.indexPathsForSelectedRowsNonNil.isWithinSameSection()
		}
	}
	
	final func allowsSink() -> Bool {
		return allowsFloat()
	}
	
	// MARK: - Moving to Top or Bottom
	
	// For iOS 14 and later
	final func moveToTopOrBottomMenu() -> UIMenu {
		let floatToTopAction = UIAction(
			title: LocalizedString.moveToTop,
			image: UIImage.floatToTopSymbol,
			handler: { _ in self.floatSelectedItemsToTopOfSection() })
		let sinkToBottomAction = UIAction(
			title: LocalizedString.moveToBottom,
			image: UIImage.sinkToBottomSymbol,
			handler: { _ in self.sinkSelectedItemsToBottomOfSection() })
		let children = [
			floatToTopAction,
			sinkToBottomAction,
		]
		return UIMenu(children: children.reversed())
	}
	
	// For iOS 13
	@objc final func showMoveToTopOrBottomActionSheet() {
		let actionSheet = UIAlertController(
			title: nil,
			message: nil,
			preferredStyle: .actionSheet)
		
		let moveToTopAlertAction = UIAlertAction(
			title: LocalizedString.moveToTop,
			style: .default,
			handler: { _ in self.floatSelectedItemsToTopOfSection() })
		let moveToBottomAlertAction = UIAlertAction(
			title: LocalizedString.moveToBottom,
			style: .default,
			handler: { _ in self.sinkSelectedItemsToBottomOfSection() })
		let cancelAlertAction = UIAlertAction.cancel(handler: nil)
		
		actionSheet.addAction(moveToTopAlertAction)
		actionSheet.addAction(moveToBottomAlertAction)
		actionSheet.addAction(cancelAlertAction)
		
		present(actionSheet, animated: true)
	}
	
	// MARK: Moving to Top
	
	@objc final func floatSelectedItemsToTopOfSection() {
		guard allowsFloat() else { return }
		
		// Make a new data source.
		
		let selectedIndexPaths = tableView.indexPathsForSelectedRowsNonNil.sorted()
		let indexesOfSelectedItems = selectedIndexPaths.map { indexOfLibraryItem(for: $0) }
		let selectedItems = selectedIndexPaths.map { libraryItem(for: $0) }
		var newItems = sectionOfLibraryItems.items
		indexesOfSelectedItems.reversed().forEach { newItems.remove(at: $0) }
		
		selectedItems.reversed().forEach { newItems.insert($0, at: 0) }
		
		// Update the data source and table view.
		setItemsAndRefreshTableView(newItems: newItems) {
			self.tableView.deselectAllRows(animated: true)
			self.didChangeRowsOrSelectedRows()
		}
	}
	
	// MARK: Moving to Bottom
	
	@objc final func sinkSelectedItemsToBottomOfSection() {
		guard allowsSink() else { return }
		
		// Make a new data source.
		
		let selectedIndexPaths = tableView.indexPathsForSelectedRowsNonNil.sorted()
		let indexesOfSelectedItems = selectedIndexPaths.map { indexOfLibraryItem(for: $0) }
		let selectedItems = selectedIndexPaths.map { libraryItem(for: $0) }
		var newItems = sectionOfLibraryItems.items
		indexesOfSelectedItems.reversed().forEach { newItems.remove(at: $0) }
		
		selectedItems.forEach { newItems.append($0) }
		
		// Update the data source and table view.
		setItemsAndRefreshTableView(newItems: newItems) {
			self.tableView.deselectAllRows(animated: true)
			self.didChangeRowsOrSelectedRows()
		}
	}
	
	// MARK: - Sorting
	
	// For iOS 14 and later
	final func sortOptionsMenu() -> UIMenu {
		let actionGroups: [[UIAction]] = sortOptionGroups.map { group in
			let actionGroup = group.map { sortOption in
				UIAction(
					title: sortOption.localizedName(),
					handler: sortActionHandler(_:))
			}
			return actionGroup
		}
		return UIMenu(
			presentsUpward: true,
			actionGroups: actionGroups)
	}
	
	// For iOS 14 and later
	private func sortActionHandler(_ sender: UIAction) {
		sortSelectedOrAllItems(sortOptionLocalizedName: sender.title)
	}
	
	// For iOS 13
	@objc final func showSortOptionsActionSheet() {
		let actionSheet = UIAlertController(
			title: LocalizedString.sortBy,
			message: nil,
			preferredStyle: .actionSheet)
		
		let flatSortOptions = sortOptionGroups.flatMap { $0 }
		let sortAlertActions = flatSortOptions.map { sortOption in
			UIAlertAction(
				title: sortOption.localizedName(),
				style: .default,
				handler: sortSelectedOrAllItems(_:))
		}
		let cancelAlertAction = UIAlertAction.cancel(handler: nil)
		
		sortAlertActions.forEach { actionSheet.addAction($0) }
		actionSheet.addAction(cancelAlertAction)
		
		actionSheet.popoverPresentationController?.barButtonItem = sortButton
		
		present(actionSheet, animated: true)
	}
	
	// For iOS 13
	private func sortSelectedOrAllItems(_ sender: UIAlertAction) {
		guard let sortOptionLocalizedName = sender.title else { return }
		sortSelectedOrAllItems(sortOptionLocalizedName: sortOptionLocalizedName)
	}
	
	private func sortSelectedOrAllItems(sortOptionLocalizedName: String) {
		guard allowsSort() else { return }
		
		// Get the indexes of the items to sort.
		let sourceIndexPaths: [IndexPath] = {
			if tableView.indexPathsForSelectedRowsNonNil.isEmpty {
				return indexPaths(forIndexOfSectionOfLibraryItems: 0)
			} else {
				return tableView.indexPathsForSelectedRowsNonNil.sorted()
			}
		}()
		let sourceIndexesOfItems = sourceIndexPaths.map { indexOfLibraryItem(for: $0) }
		
		// Get the items to sort.
		let itemsToSort = sourceIndexesOfItems.map { sectionOfLibraryItems.items[$0] }
		
		// Sort the items.
		let sortedItems = sorted(
			itemsToSort,
			sortOptionLocalizedName: sortOptionLocalizedName)
		
		// Make a new data source.
		var newItems = sectionOfLibraryItems.items
		sourceIndexesOfItems.reversed().forEach { newItems.remove(at: $0) }
		sortedItems.indices.forEach {
			let sortedItem = sortedItems[$0]
			let destinationIndex = sourceIndexesOfItems[$0]
			newItems.insert(sortedItem, at: destinationIndex)
		}
		
		// Update the data source and table view.
		setItemsAndRefreshTableView(newItems: newItems) {
			self.tableView.deselectAllRows(animated: true)
			self.didChangeRowsOrSelectedRows()
		}
	}
	
	// Sorting should be stable! Multiple items with the same name, disc number, or whatever property we're sorting by should stay in the same order.
	private func sorted(
		_ items: [NSManagedObject],
		sortOptionLocalizedName: String?
	) -> [NSManagedObject] {
		switch sortOptionLocalizedName {
		
		case LocalizedString.title:
			guard let collections = items as? [Collection] else {
				return items
			}
			return collections.sorted {
				let collectionTitle0 = $0.title ?? ""
				let collectionTitle1 = $1.title ?? ""
				// Don't sort Strings by <. That puts all capital letters before all lowercase letters, meaning "Z" comes before "a".
				return collectionTitle0.precedesAlphabeticallyFinderStyle(collectionTitle1)
			}
		
		// Albums only
		case LocalizedString.newestFirst:
			guard let albums = items as? [Album] else {
				return items
			}
			print("")
			albums.forEach {
				print($0.titleFormattedOrPlaceholder())
			}
			return albums.sorted {
				print("")
				print(String(describing: $0.mpMediaItemCollection()?.representativeItem?.albumTitle))
				print(String(describing: $1.mpMediaItemCollection()?.representativeItem?.albumTitle))
				
				let leftReleaseDate = $0.releaseDateEstimate
				let rightReleaseDate = $1.releaseDateEstimate
				// Either can be nil
				
				// Leave Albums in the same order if they both have no release date, or the same release date.
				guard leftReleaseDate != rightReleaseDate else {
//					return false
					return true
				}
				
				// Move unknown release date to the end
				guard let rightReleaseDate = rightReleaseDate else {
					return true
				}
				guard let leftReleaseDate = leftReleaseDate else {
					return false
				}
				
				return leftReleaseDate > rightReleaseDate
			}
			
			
//			let commonDate = Date()
//			return albums.sorted {
//				$0.releaseDateEstimate ?? commonDate >
//					$1.releaseDateEstimate ?? commonDate
//			}
		case LocalizedString.oldestFirst:
			guard let albums = items as? [Album] else {
				return items
			}
			return albums.sorted {
				let leftReleaseDate = $0.releaseDateEstimate
				let rightReleaseDate = $1.releaseDateEstimate
				// Either can be nil

				// Leave Albums in the same order if they both have no release date, or the same release date.
				guard leftReleaseDate != rightReleaseDate else {
//					return false
					return true
				}

				// Move unknown release date to the end
				guard let rightReleaseDate = rightReleaseDate else {
					return true
				}
				guard let leftReleaseDate = leftReleaseDate else {
					return false
				}

				return leftReleaseDate < rightReleaseDate
			}
			
			
//			let commonDate = Date()
//			return albums.sorted {
//				$0.releaseDateEstimate ?? commonDate <
//					$1.releaseDateEstimate ?? commonDate
//			}
		
		// Songs only
		case LocalizedString.trackNumber:
			guard let songs = items as? [Song] else {
				return items
			}
			// Actually, return the songs grouped by disc number, and sorted by track number within each disc.
//			return songs.sorted {
//
//
//			}
			
			
			let sortedByTrackNumber = songs.sorted {
				$0.mpMediaItem()?.albumTrackNumber ?? 0 <
					$1.mpMediaItem()?.albumTrackNumber ?? 0
			}
			let sortedByTrackNumberWithZeroAtEnd = sortedByTrackNumber.sorted {
				$1.mpMediaItem()?.albumTrackNumber ?? 0 == 0
			}
			let sortedByDiscNumber = sortedByTrackNumberWithZeroAtEnd.sorted {
				$0.mpMediaItem()?.discNumber ?? 0 <
					$1.mpMediaItem()?.discNumber ?? 0
			}
			// As of iOS 14.0 beta 5, MediaPlayer reports unknown disc numbers as 1, so there's no need to move disc 0 to the end.
			return sortedByDiscNumber
			
		case LocalizedString.reverse:
			return items.reversed()
			
		default:
			print("The user tried to sort by “\(sortOptionLocalizedName ?? "")”, which isn’t a supported option. It might be misspelled.")
			return items
		}
	}
	
}
