// 2021-08-12

import CoreData

protocol LibraryViewModel {
	// You must add a `didSet` that calls `Library.renumber(items)`.
	var items: [NSManagedObject] { get set }
	
	func itemIndex(forRow row: Int) -> Int
	func withRefreshedData() -> Self
	func rowIdentifiers() -> [AnyHashable]
}

struct AlbumsViewModel {
	// `LibraryViewModel`
	var items: [NSManagedObject] { didSet { Database.renumber(items) } }
}
extension AlbumsViewModel: LibraryViewModel {
	func itemIndex(forRow row: Int) -> Int { return row }
	func withRefreshedData() -> Self { return Self() }
	func rowIdentifiers() -> [AnyHashable] {
		return items.map { $0.objectID }
	}
}
extension AlbumsViewModel {
	init() {
		guard
			let collection = Collection.allFetched(sorted: false, context: Database.viewContext).first,
			let context = collection.managedObjectContext
		else {
			// We deleted `collection`
			items = []
			return
		}
		items = Album.allFetched(sorted: true, inCollection: collection, context: context)
	}
}

struct SongsViewModel {
	static let prerowCount = 1
	
	// `LibraryViewModel`
	var items: [NSManagedObject] { didSet { Database.renumber(items) } }
}
extension SongsViewModel: LibraryViewModel {
	func itemIndex(forRow row: Int) -> Int { return row - Self.prerowCount }
	func withRefreshedData() -> Self {
		// Get the `Album` from the first non-deleted `Song`.
		guard let album = (items as! [Song]).first(where: { $0.container != nil })?.container else {
			return Self(items: [])
		}
		return Self(album: album)
	}
	func rowIdentifiers() -> [AnyHashable] {
		let itemRowIDs = items.map { AnyHashable($0.objectID) }
		return [42] + itemRowIDs
	}
}
extension SongsViewModel {
	init(album: Album) {
		items = Song.allFetched(sorted: true, inAlbum: album, context: album.managedObjectContext!)
	}
}
