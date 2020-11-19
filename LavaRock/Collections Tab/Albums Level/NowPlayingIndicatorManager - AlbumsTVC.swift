//
//  NowPlayingIndicatorManager - AlbumsTVC.swift
//  LavaRock
//
//  Created by h on 2020-11-19.
//

import UIKit

extension AlbumsTVC: NowPlayingIndicatorManager {
	
	final func isNowPlayingItem(at indexPath: IndexPath) -> Bool {
		if
			let rowAlbum = indexedLibraryItems[indexPath.row - numberOfRowsAboveIndexedLibraryItems] as? Album,
			PlayerControllerManager.shared.currentSong?.container?.objectID == rowAlbum.objectID
		{
			return true
		} else {
			return false
		}
	}
	
}
