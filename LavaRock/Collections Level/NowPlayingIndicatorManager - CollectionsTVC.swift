//
//  NowPlayingIndicatorManager - CollectionsTVC.swift
//  LavaRock
//
//  Created by h on 2020-11-19.
//

import UIKit

extension CollectionsTVC: NowPlayingIndicatorManager {
	
	final func isItemNowPlaying(at indexPath: IndexPath) -> Bool {
		if
			let rowCollection = libraryItem(for: indexPath) as? Collection,
			PlayerControllerManager.nowPlayingSong?.container?.container?.objectID == rowCollection.objectID
		{
			return true
		} else {
			return false
		}
	}
	
}
