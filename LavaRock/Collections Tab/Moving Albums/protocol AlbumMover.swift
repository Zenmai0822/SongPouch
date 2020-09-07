//
//  protocol AlbumMover.swift
//  LavaRock
//
//  Created by h on 2020-08-04.
//

import UIKit
import CoreData

protocol AlbumMover {
	var moveAlbumsClipboard: AlbumMoverClipboard? { get set }
	
	func beginObservingAlbumMoverNotifications()
	func mocDidMergeChanges()
}
