//
//  extension Notification.Name.swift
//  LavaRock
//
//  Created by h on 2020-09-14.
//

import Foundation

extension Notification.Name {
//	static let LRPlayerManagerDidSetUp = Self.init("PlayerManager has set itself up. Instances that depend on that fact should observe this notification and respond now.")
	static let LRDidImportChanges = Notification.Name("MusicLibraryManager has saved changes from the built-in Music app’s library into the Core Data store. Instances that depend on that fact should observe this notification and refresh their data now.")
	static let LRDidMoveAlbums = Notification.Name("The user has moved (one or more) Albums to another (existing or new) Collection.")
}
