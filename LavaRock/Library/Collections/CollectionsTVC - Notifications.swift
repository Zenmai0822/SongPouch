//
//  CollectionsTVC - Notifications.swift
//  LavaRock
//
//  Created by h on 2020-09-10.
//

import UIKit
import CoreData

extension CollectionsTVC {
	// MARK: - Player
	
	final override func reflectPlayer() {
		super.reflectPlayer()
		
		if let viewModel = viewModel as? NowPlayingDetermining {
			freshenNowPlayingIndicators(accordingTo: viewModel)
		}
	}
	
	// MARK: Library Items
	
	final override func freshenLibraryItems() {
		switch purpose {
		case .willOrganizeAlbums:
			break
		case .organizingAlbums:
			break
		case .movingAlbums:
			break
		case .browsing:
			willFreshenLibraryItems()
			
			if viewModelBeforeCombining != nil {
				revertCombine(thenSelect: [])
			}
			
			super.freshenLibraryItems()
		}
	}
}
