//
//  AlbumsViewModel.swift
//  LavaRock
//
//  Created by h on 2021-08-14.
//

import UIKit
import CoreData

struct AlbumsViewModel {
	// `LibraryViewModel`
	let viewContainer: LibraryViewContainer
	let context: NSManagedObjectContext
	let numberOfPresections = Section_I(0)
	var numberOfPrerowsPerSection: Row_I { Row_I(prerowsInEachSection.count) }
	var groups: ColumnOfLibraryItems
	
	enum Prerow {
		case moveHere
	}
	var prerowsInEachSection: [Prerow]
}
extension AlbumsViewModel: LibraryViewModel {
	static let entityName = "Album"
	
	func viewContainerIsSpecific() -> Bool {
		return Enabling.multicollection ? false : true
	}
	
	func bigTitle() -> String {
		switch viewContainer {
		case .library:
			return LocalizedString.albums
		case
				.container(let container),
				.deleted(let container):
			let collection = container as! Collection
			return collection.title ?? LocalizedString.albums
		}
	}
	
	func prerowIdentifiersInEachSection() -> [AnyHashable] {
		return prerowsInEachSection
	}
	
	func allowsSortOption(
		_ sortOption: LibrarySortOption,
		forItems items: [NSManagedObject]
	) -> Bool {
		switch sortOption {
		case .title:
			return false
		case
				.newestFirst,
				.oldestFirst:
			guard let albums = items as? [Album] else {
				return false
			}
			return albums.contains { $0.releaseDateEstimate != nil }
		case .trackNumber:
			return false
		case
				.shuffle,
				.reverse:
			return true
		}
	}
	
	func updatedWithFreshenedData() -> Self {
		let freshenedViewContainer = viewContainer.freshened()
		return Self(
			viewContainer: freshenedViewContainer,
			context: context,
			prerowsInEachSection: prerowsInEachSection)
	}
}
extension AlbumsViewModel {
	init(
		viewContainer: LibraryViewContainer,
		context: NSManagedObjectContext,
		prerowsInEachSection: [Prerow]
	) {
		self.viewContainer = viewContainer
		self.context = context
		self.prerowsInEachSection = prerowsInEachSection
		
		// Check `viewContainer` to figure out which `Album`s to show.
		let containers: [NSManagedObject] = {
			switch viewContainer {
			case .library:
				let allCollections = Collection.allFetched(ordered: true, via: context)
				return allCollections
			case .container(let container):
				let collection = container as! Collection
				return [collection]
			case .deleted:
				return []
			}}()
		groups = containers.map {
			CollectionsOrAlbumsGroup(
				entityName: Self.entityName,
				container: $0,
				context: context)
		}
	}
	
	func albumNonNil(at indexPath: IndexPath) -> Album {
		return itemNonNil(at: indexPath) as! Album
	}
	
	// Similar to `SongsViewModel.album`.
	func collection(for section: Section_I) -> Collection {
		let group = group(for: section)
		return group.container as! Collection
	}
	
	enum RowCase {
		case prerow(Prerow)
		case album
	}
	func rowCase(for indexPath: IndexPath) -> RowCase {
		let row = indexPath.row_i
		if row < numberOfPrerowsPerSection {
			return .prerow(prerowsInEachSection[row.value])
		} else {
			return .album
		}
	}
	
	// MARK: - Organizing
	
	// Returns `true` if the albums to organize have at least 2 different album artists.
	// The “albums to organize” are the selected albums, if any, or all the albums, if this is a specifically opened `Collection`.
	func allowsOrganize(
		selectedIndexPaths: [IndexPath]
	) -> Bool {
		let indexPathsToOrganize = unsortedOrForAllItemsIfNoneSelectedAndViewContainerIsSpecific(
			selectedIndexPaths: selectedIndexPaths)
		let albumsToOrganize = indexPathsToOrganize.map { albumNonNil(at: $0) }
		return albumsToOrganize.contains {
			$0.representativeAlbumArtistFormattedOrPlaceholder() != $0.container?.title
		}
	}
	
	// MARK: - “Move Albums” Sheet
	
	func updatedAfterMoving(
		albumsWith albumIDs: [NSManagedObjectID],
		to section: Section_I
	) -> Self {
		let destinationCollection = collection(for: section)
		
		destinationCollection.moveAlbumsToBeginning(
			with: albumIDs,
			possiblyToSameCollection: true,
			via: context)
		
		return AlbumsViewModel(
			viewContainer: viewContainer,
			context: context,
			prerowsInEachSection: [])
	}
}
