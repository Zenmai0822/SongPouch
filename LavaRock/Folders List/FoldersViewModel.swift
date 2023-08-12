//
//  FoldersViewModel.swift
//  LavaRock
//
//  Created by h on 2021-08-14.
//

import CoreData

struct FoldersViewModel {
	// `LibraryViewModel`
	let context: NSManagedObjectContext
	var groups: ColumnOfLibraryItems
}
extension FoldersViewModel: LibraryViewModel {
	func prerowCount() -> Int { return 0 }
	func prerowIdentifiers() -> [AnyHashable] { return [] }
	func updatedWithFreshenedData() -> Self {
		return Self(context: context)
	}
}
extension FoldersViewModel {
	init(context: NSManagedObjectContext
	) {
		self.context = context
		groups = [
			FoldersGroup(context: context)
		]
	}
	
	func folderNonNil(atRow: Int) -> Collection {
		return itemNonNil(atRow: atRow) as! Collection
	}
	
	private func updatedWithItemsInOnlyGroup(_ newItems: [NSManagedObject]) -> Self {
		var twin = self
		twin.groups[0].items = newItems
		return twin
	}
	
	// MARK: - Renaming
	
	func renameAndReturnDidChangeTitle(
		atRow: Int,
		proposedTitle: String?
	) -> Bool {
		guard
			let proposedTitle = proposedTitle,
			proposedTitle != ""
		else {
			return false
		}
		let newTitle = proposedTitle.truncated(toMaxLength: 256) // In case the user entered a dangerous amount of text
		
		let folder = folderNonNil(atRow: atRow)
		let oldTitle = folder.title
		folder.title = newTitle
		return oldTitle != folder.title
	}
	
	// MARK: - “Move albums” sheet
	
	static let indexOfNewFolder = 0
	
	func updatedAfterCreating() -> Self {
		let newFolder = Collection(context: context)
		newFolder.title = LRString.untitledFolder
		// When we call `setItemsAndMoveRows`, the property observer will set each `Collection.index` for us.
		
		var newItems = libraryGroup().items
		newItems.insert(newFolder, at: Self.indexOfNewFolder)
		
		return updatedWithItemsInOnlyGroup(newItems)
	}
	
	func updatedAfterDeletingNewFolder() -> Self {
		let newItems = itemsAfterDeletingNewFolder()
		
		return updatedWithItemsInOnlyGroup(newItems)
	}
	
	private func itemsAfterDeletingNewFolder() -> [NSManagedObject] {
		let oldItems = libraryGroup().items
		guard
			let folder = oldItems[Self.indexOfNewFolder] as? Collection,
			folder.isEmpty()
		else {
			return oldItems
		}
		
		context.delete(folder)
		
		var newItems = libraryGroup().items
		newItems.remove(at: Self.indexOfNewFolder)
		return newItems
	}
}
