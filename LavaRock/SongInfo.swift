// 2021-12-24

import UIKit

typealias AlbumID = Int64
typealias SongID = Int64

protocol SongInfo {
	var albumID: AlbumID { get }
	var songID: SongID { get }
	
	var albumArtistOnDisk: String? { get }
	var albumTitleOnDisk: String? { get }
	var discCountOnDisk: Int { get }
	var discNumberOnDisk: Int { get }
	var trackNumberOnDisk: Int { get }
	static var unknownTrackNumber: Int { get }
	var titleOnDisk: String? { get }
	var artistOnDisk: String? { get }
	var dateAddedOnDisk: Date { get }
	var releaseDateOnDisk: Date? { get }
	func coverArt(resolutionAtLeastInPoints: CGSize) -> UIImage?
}
extension SongInfo {
	// MARK: - Sorting
	
	// Behavior is undefined if you compare with a `SongInfo` from the same album.
	func precedesInDefaultOrder(inDifferentAlbum other: SongInfo) -> Bool {
		let myAlbumArtist = albumArtistOnDisk
		let otherAlbumArtist = other.albumArtistOnDisk
		// Either can be `nil`
		
		guard myAlbumArtist != otherAlbumArtist else {
			let myAlbumTitle = albumTitleOnDisk
			let otherAlbumTitle = other.albumTitleOnDisk
			// Either can be `nil`
			
			guard myAlbumTitle != otherAlbumTitle else {
				return true
				// Maybe we could go further with some other criterion
			}
			
			// Move unknown album title to end
			guard otherAlbumTitle != "", let otherAlbumTitle = otherAlbumTitle else { return true }
			guard myAlbumTitle != "", let myAlbumTitle = myAlbumTitle else { return false }
			
			return myAlbumTitle.precedesInFinder(otherAlbumTitle)
		}
		
		// Move unknown album artist to end
		guard let otherAlbumArtist, otherAlbumArtist != "" else { return true }
		guard let myAlbumArtist, myAlbumArtist != "" else { return false }
		
		return myAlbumArtist.precedesInFinder(otherAlbumArtist)
	}
	
	// Behavior is undefined if you compare with a `SongInfo` from a different album.
	func precedesNumerically(
		inSameAlbum other: SongInfo,
		shouldResortToTitle: Bool
	) -> Bool {
		// Sort by disc number
		let myDisc = discNumberOnDisk
		let otherDisc = other.discNumberOnDisk
		guard myDisc == otherDisc else {
			return myDisc < otherDisc
		}
		
		let myTrack = trackNumberOnDisk
		let otherTrack = other.trackNumberOnDisk
		
		if shouldResortToTitle {
			guard myTrack != otherTrack else {
				// Sort by song title
				let myTitle = titleOnDisk ?? ""
				let otherTitle = other.titleOnDisk ?? ""
				return myTitle.precedesInFinder(otherTitle)
			}
		} else {
			// At this point, leave elements in the same order if they both have no track number, or the same track number.
			// However, as of iOS 14.7, when using `sorted(by:)`, returning `true` here doesn’t always keep the elements in the same order. Call this method in `sortedMaintainingOrderWhen` to guarantee stable sorting.
			guard myTrack != otherTrack else { return true }
		}
		
		// Move unknown track number to the end
		guard otherTrack != type(of: other).unknownTrackNumber else { return true }
		guard myTrack != Self.unknownTrackNumber else { return false }
		
		return myTrack < otherTrack
	}
	
	// MARK: Formatted attributes
	
	var shouldShowDiscNumber: Bool {
		return discCountOnDisk >= 2 || discNumberOnDisk >= 2
	}
	func discAndTrackFormatted() -> String {
		return "\(discNumberOnDisk)\(LRString.interpunct)\(trackFormatted())"
	}
	func trackFormatted() -> String {
		guard trackNumberOnDisk != Self.unknownTrackNumber else { return LRString.octothorpe }
		return String(trackNumberOnDisk)
	}
}

// MARK: - Apple Music

import MediaPlayer
extension MPMediaItem: SongInfo {
	final var albumID: AlbumID { AlbumID(bitPattern: albumPersistentID) }
	final var songID: SongID { SongID(bitPattern: persistentID) }
	
	// Media Player reports unknown values as…
	final var albumArtistOnDisk: String? { albumArtist } // `nil`, as of iOS 14.7 developer beta 5
	final var albumTitleOnDisk: String? { albumTitle } // `""`, as of iOS 14.7 developer beta 5
	final var discCountOnDisk: Int { discCount } // `0`, as of iOS 15.0 RC
	final var discNumberOnDisk: Int { discNumber } // `1`, as of iOS 14.7 developer beta 5
	static let unknownTrackNumber = 0 // As of iOS 14.7 developer beta 5
	final var trackNumberOnDisk: Int { albumTrackNumber }
	final var titleOnDisk: String? { title } // …we don’t know, because Apple Music for Mac as of version 1.1.5.74 doesn’t allow blank song titles. But that means we shouldn’t need to move unknown song titles to the end.
	final var artistOnDisk: String? { artist }
	final var dateAddedOnDisk: Date { dateAdded }
	final var releaseDateOnDisk: Date? { releaseDate }
	final func coverArt(resolutionAtLeastInPoints: CGSize) -> UIImage? {
		return artwork?.image(at: resolutionAtLeastInPoints)
	}
}
