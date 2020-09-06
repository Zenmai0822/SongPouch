//
//  Editing (SongsTVC).swift
//  LavaRock
//
//  Created by h on 2020-08-23.
//

import UIKit

extension SongsTVC {
	
	// Note: We handle rearranging in UITableViewDataSource and UITableViewDelegate methods.
	
	// MARK: - Moving Rows to Top
	
	override func moveSelectedItemsToTop() {
		moveItemsUp(
			from: tableView.indexPathsForSelectedRows,
			to: IndexPath(row: numberOfRowsAboveActiveLibraryItems, section: 0))
	}
	
	// MARK: - Sorting
	
	// In the parent class, sortSelectedOrAllItems is split into two parts, where the first part is like this stub here, in order to allow this class to inject numberOfRowsAboveActiveLibraryItems. This is bad practice.
	override func sortSelectedOrAllItems(sender: UIAlertAction) {
		let indexPathsToSort = selectedOrEnumeratedIndexPathsIn(
			section: 0,
			firstRow: numberOfRowsAboveActiveLibraryItems,
			lastRow: tableView.numberOfRows(inSection: 0) - 1)
		sortSelectedOrAllItemsPart2(forIndexPaths: indexPathsToSort, sender: sender)
	}
	
}
