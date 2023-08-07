//
//  SongsGroup.swift
//  LavaRock
//
//  Created by h on 2021-07-02.
//

import CoreData

struct SongsGroup {
	// `LibraryGroup`
	let container: NSManagedObject?
	private(set) var items: [NSManagedObject] {
		didSet {
			items.enumerated().forEach { (currentIndex, libraryItem) in
				libraryItem.setValue(
					Int64(currentIndex),
					forKey: "Index")
			}
		}
	}
	
	private(set) var spacerTrackNumberText: String = Self.spacerTrackNumberText_Default
	static let spacerTrackNumberText_Default: String = "00"
}
extension SongsGroup: LibraryGroup {
	mutating func setItems(_ newItems: [NSManagedObject]) {
		items = newItems
	}
	
	init(
		album: Album?,
		context: NSManagedObjectContext
	) {
		items = Song.allFetched(sorted: true, inAlbum: album, context: context)
		self.container = album
		
		spacerTrackNumberText = {
			guard let representative = (container as? Album)?.representativeSongInfo() else {
				return Self.spacerTrackNumberText_Default
			}
			let infos: [SongInfo] = items.compactMap { ($0 as? Song)?.songInfo() }
			// At minimum, reserve the width of 2 digits, plus an interpunct if appropriate.
			// At maximum, reserve the width of 4 digits plus an interpunct.
			if representative.shouldShowDiscNumber {
				var widestText = Self.spacerTrackNumberText_Default
				for info in infos {
					let discAndTrack = ""
					+ info.discNumberFormatted()
					+ (info.trackNumberFormattedOptional() ?? "")
					if discAndTrack.count >= 4 {
						return LRString.interpunct + "0000"
					}
					if discAndTrack.count > widestText.count {
						widestText = discAndTrack
					}
				}
				return LRString.interpunct + widestText
			} else {
				var widestText = Self.spacerTrackNumberText_Default
				for info in infos {
					let track = info.trackNumberFormattedOptional() ?? ""
					if track.count >= 4 {
						return "0000"
					}
					if track.count > widestText.count {
						widestText = track
					}
				}
				return String(widestText)
			}
		}()
	}
}
