//
//  GroupOfCollectionsOrAlbums.swift
//  LavaRock
//
//  Created by h on 2021-03-04.
//

import CoreData

struct GroupOfCollectionsOrAlbums: GroupOfLibraryItems {
	
	// MARK: GroupOfLibraryItems
	
	let container: NSManagedObject?
	
	var items: [NSManagedObject] { private_items }
	private var private_items: [NSManagedObject] = [] {
		didSet {
			private_items.indices.forEach { currentIndex in
				private_items[currentIndex].setValue(
					Int64(currentIndex),
					forKey: "index")
			}
		}
	}
	
	mutating func setItems(_ newItems: [NSManagedObject]) {
		private_items = newItems
	}
	
	// MARK: Miscellaneous
	
	init(
		entityName: String,
		container: NSManagedObject?,
		context: NSManagedObjectContext
	) {
		self.container = container
		
		private_items = itemsFetched( // Doesn't trigger the property observer
			entityName: entityName,
			context: context)
	}
	
}
