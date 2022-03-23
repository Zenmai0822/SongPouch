//
//  SongsTVC - Notifications.swift
//  LavaRock
//
//  Created by h on 2020-09-10.
//

import UIKit

extension SongsTVC {
	// MARK: - Player
	
	final override func reflectPlayer() {
		super.reflectPlayer()
		
		indicateNowPlayingOnVisibleCells(accordingTo: self)
	}
	
	// MARK: - Library Items
	
	final override func shouldDismissAllViewControllersBeforeFreshenLibraryItems() -> Bool {
		if willPlayLaterAlertIsPresented {
			return false
		}
		
		return super.shouldDismissAllViewControllersBeforeFreshenLibraryItems()
	}
}
