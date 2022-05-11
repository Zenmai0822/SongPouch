//
//  ConsoleVC - Notifications.swift
//  LavaRock
//
//  Created by h on 2022-03-27.
//

import Foundation

extension ConsoleVC: PlayerReflecting {
	func reflectPlaybackState() {
		reflectPlayhead_console()
	}
}
extension ConsoleVC {
	// MARK: - Player
	
	final func reflectPlayhead_console() {
		queueTable.indexPathsForVisibleRowsNonNil.forEach { visibleIndexPath in
			guard let cell = queueTable.cellForRow(
				at: visibleIndexPath) as? PlayheadReflectable
			else { return }
			cell.reflectPlayhead(
				containsPlayhead: Self.rowContainsPlayhead(at: visibleIndexPath))
		}
	}
}
