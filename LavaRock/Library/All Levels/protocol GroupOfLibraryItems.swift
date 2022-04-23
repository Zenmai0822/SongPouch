//
//  protocol GroupOfLibraryItems.swift
//  LavaRock
//
//  Created by h on 2021-07-02.
//

import CoreData

protocol GroupOfLibraryItems {
	var container: NSManagedObject? { get }
	
	var items: [NSManagedObject] { get }
	/*
	 Force callers to use `setItems` rather than modifying `items` directly. That helps callers keep `items` in a coherent state by forcing them to finalize their changes explicitly.
	 
	 It would be nice to make `items` `private(set)`, but then it couldn’t satisfy the protocol requirement. Instead, include …
	 ```
	 var items: [NSManagedObject] { private_items }
	 private var private_items: [NSManagedObject] = []
	 ```
	 
	 For safety, disable the default memberwise initializer (for structs), to prevent callers from initializing `private_items` incorrectly. Include this in your custom initializer:
	 ```
	 private_items = fetchedItems()
	 ```
	 
	 You can also use …
	 ```
	 private(set) lazy var private_items = fetchedItems()
	 ```
	 … but you’ll have to make `items` `mutating get`, and you’ll still have to disable the default memberwise initializer to be safe.
	 
	 You should also give `private_items` a property observer that sets the `index` attribute on each `NSManagedObject`, exactly like `[LibraryItem].reindex`:
	 //	didSet {
	 //		private_items.enumerated().forEach { (currentIndex, libraryItem) in
	 //			libraryItem.setValue(
	 //				Int64(currentIndex),
	 //				forKey: "index")
	 //		}
	 //	}
	 */
	
	mutating func setItems(_ newItems: [NSManagedObject])
}
extension GroupOfLibraryItems {
	subscript(index: Int) -> NSManagedObject {
		return items[index]
	}
	
	func itemsFrom(_ itemIndex: ItemIndex) -> [NSManagedObject] {
		return Array(items[itemIndex.__...])
	}
	
	// Similar to `Collection.allFetched`, `Album.allFetched`, and `Song.allFetched`.
	func itemsFetched(
		entityName: String,
		context: NSManagedObjectContext
	) -> [NSManagedObject] {
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
		if let container = container {
			fetchRequest.predicate = NSPredicate(
				format: "container == %@",
				container)
		}
		return context.objectsFetched(for: fetchRequest)
	}
}
