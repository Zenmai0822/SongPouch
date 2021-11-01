//
//  extension UITableView.swift
//  LavaRock
//
//  Created by h on 2020-08-06.
//

import UIKit

extension UITableView {
	
	// MARK: - IndexPaths
	
	final var indexPathsForSelectedRowsNonNil: [IndexPath] {
		return indexPathsForSelectedRows ?? []
	}
	
	final func indexPathsForRows(
		inSection section: Int,
		firstRow: Int
	) -> [IndexPath] {
		let lastRow = numberOfRows(inSection: section) - 1
		guard lastRow >= 0 else {
			// The section has 0 rows.
			return []
		}
		return indexPathsForRows(
			inSection: section,
			firstRow: firstRow,
			lastRow: lastRow)
	}
	
	private func indexPathsForRows(
		inSection section: Int,
		firstRow: Int,
		lastRow: Int
	) -> [IndexPath] {
		let rows = Array(firstRow ... lastRow)
		let result = rows.map { IndexPath(row: $0, section: section) }
		return result
	}
	
	// MARK: - Deselecting
	
	final func deselectAllRows(animated: Bool) {
		deselectRows(at: indexPathsForSelectedRowsNonNil, animated: animated)
	}
	
	final func deselectSection(_ section: Int, animated: Bool) {
		let selectedInSection = indexPathsForSelectedRowsNonNil.filter { $0.section == section }
		deselectRows(at: selectedInSection, animated: animated)
	}
	
	private func deselectRows(at indexPaths: [IndexPath], animated: Bool) {
		indexPaths.forEach {
			deselectRow(at: $0, animated: animated) // As of iOS 14.2 developer beta 1, this doesn't animate for some reason. It works right on iOS 13.5.1.
		}
	}
	
}
