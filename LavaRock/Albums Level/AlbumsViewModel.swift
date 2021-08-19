//
//  AlbumsViewModel.swift
//  AlbumsViewModel
//
//  Created by h on 2021-08-14.
//

import UIKit
import CoreData

struct AlbumsViewModel: LibraryViewModel {
	
	// MARK: - LibraryViewModel
	
	static let entityName = "Album"
	
	let context: NSManagedObjectContext
	let numberOfSectionsAboveLibraryItems = 0 //
	let numberOfRowsAboveLibraryItemsInEachSection = 0
	
	var groups: [GroupOfLibraryItems]
	
	// MARK: - Miscellaneous
	
	init(
		containers: [NSManagedObject],
		context: NSManagedObjectContext
	) {
		self.context = context
		groups = containers.map {
			GroupOfCollectionsOrAlbums(
				entityName: Self.entityName,
				container: $0,
				context: context)
		}
	}
	
	// Similar to SongsViewModel.container.
	func container(forSection section: Int) -> Collection { // "container"? could -> Collection satisfy a protocol requirement -> NSManagedObject as a covariant?
		let group = group(forSection: section)
		return group.container as! Collection
	}
	
	// MARK: - Editing
	
	// MARK: Allowing
	
	func allowsMoveOrOrganize(
		selectedIndexPaths: [IndexPath]
	) -> Bool {
		guard !isEmpty() else {
			return false
		}
		
		if selectedIndexPaths.isEmpty {
			return groups.count == 1
		} else {
			return selectedIndexPaths.isWithinSameSection()
		}
	}
	
	func allowsMove(
		selectedIndexPaths: [IndexPath]
	) -> Bool {
		return allowsMoveOrOrganize(selectedIndexPaths: selectedIndexPaths)
	}
	
	// MARK: - “Moving Albums” Mode
	
	// MARK: Ending Moving
	
	func itemsAfterMovingHere(
		albumsWith albumIDs: [NSManagedObjectID],
		indexOfGroup: Int //
	) -> [NSManagedObject] {
		guard let destinationCollection = groups[indexOfGroup].container as? Collection else {
			return groups[indexOfGroup].items
		}
		
		destinationCollection.moveHere(
			albumsWith: albumIDs,
			context: context)
		
		let newItems = destinationCollection.albums()
		return newItems
	}
	
}
