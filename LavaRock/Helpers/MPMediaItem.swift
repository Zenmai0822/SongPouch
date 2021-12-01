//
//  MPMediaItem.swift
//  LavaRock
//
//  Created by h on 2021-07-10.
//

import MediaPlayer

extension MPMediaItem {
	
	// As of iOS 14.7 developer beta 5, MediaPlayer reports unknown track numbers as 0.
	static let unknownTrackNumber = 0
	
	// MARK: - Predicates for Sorting
	
	// Note: Behavior is undefined if you compare with an MPMediaItem from the same album.
	// Verified as of build 157 on iOS 14.7 developer beta 5.
	final func precedesInDefaultOrder(inDifferentAlbum other: MPMediaItem) -> Bool {
		let myAlbumArtist = albumArtist
		let otherAlbumArtist = other.albumArtist
		// Either can be nil
		
		guard myAlbumArtist != otherAlbumArtist else {
			let myAlbumTitle = albumTitle
			let otherAlbumTitle = other.albumTitle
			// Either can be nil
			
			guard myAlbumTitle != otherAlbumTitle else {
				return true // Maybe we could go further with some other criterion
			}
			
			// Move unknown album title to end
			// As of iOS 14.7 developer beta 5, MediaPlayer reports unknown album titles as "".
			guard otherAlbumTitle != "", let otherAlbumTitle = otherAlbumTitle else {
				return true
			}
			guard myAlbumTitle != "", let myAlbumTitle = myAlbumTitle else {
				return false
			}
			
			// Sort by album title
			return myAlbumTitle.precedesAlphabeticallyFinderStyle(otherAlbumTitle)
		}
		
		// Move unknown album artist to end
		// As of iOS 14.7 developer beta 5, MediaPlayer reports unknown album artists as nil.
		guard let otherAlbumArtist = otherAlbumArtist, otherAlbumArtist != "" else {
			return true
		}
		guard let myAlbumArtist = myAlbumArtist, myAlbumArtist != "" else {
			return false
		}
		
		// Sort by album artist
		return myAlbumArtist.precedesAlphabeticallyFinderStyle(otherAlbumArtist)
	}
	
	final func precedesInDefaultOrder(inSameAlbum other: MPMediaItem) -> Bool {
		return precedesInDisplayOrder(
			inSameAlbum: other,
			shouldResortToTitle: true)
	}
	
	final func precedesForSortOptionTrackNumber(_ other: MPMediaItem) -> Bool {
		return precedesInDisplayOrder(
			inSameAlbum: other,
			shouldResortToTitle: false)
	}
	
	// Note: Behavior is undefined if you compare with an MPMediaItem from a different album.
	// Verified as of build 154 on iOS 14.7 developer beta 5.
	private func precedesInDisplayOrder(
		inSameAlbum other: MPMediaItem,
		shouldResortToTitle: Bool
	) -> Bool {
		// Sort by disc number
		// As of iOS 14.7 developer beta 5, MediaPlayer reports unknown disc numbers as 1.
		let myDisc = discNumber
		let otherDisc = other.discNumber
		guard myDisc == otherDisc else {
			return myDisc < otherDisc
		}
		
		let myTrack = albumTrackNumber
		let otherTrack = other.albumTrackNumber
		
		if shouldResortToTitle {
			guard myTrack != otherTrack else {
				// Sort by song title
				// Music for Mac as of version 1.1.5.74 doesn't allow blank song titles, so we shouldn't need to move unknown song titles to the end.
				// Note: We don't know whether MediaPlayer would report unknown song titles as nil or "".
				let myTitle = title ?? ""
				let otherTitle = other.title ?? ""
				return myTitle.precedesAlphabeticallyFinderStyle(otherTitle)
			}
		} else {
			// At this point, leave elements in the same order if they both have no release date, or the same release date.
			// However, as of iOS 14.7, when using sorted(by:), returning `true` here doesn't always keep the elements in the same order. Use sortedMaintainingOrderWhen(areEqual:areInOrder:) to guarantee stable sorting.
//			guard myTrack != otherTrack else {
//				return true
//			}
		}
		
		// Move unknown track number to the end
		guard otherTrack != Self.unknownTrackNumber else {
			return true
		}
		guard myTrack != Self.unknownTrackNumber else {
			return false
		}
		
		// Sort by track number
		return myTrack < otherTrack
	}
	
	// MARK: - Formatted Attributes
	
	static let unknownTitlePlaceholder = "—" // Em dash
	static let unknownTrackNumberPlaceholder = "‒" // Figure dash
	
	final func discAndTrackNumberFormatted() -> String {
		let discNumberString = String(discNumber)
		let trackNumberString
		= (albumTrackNumber == Self.unknownTrackNumber)
		? ""
		: String(albumTrackNumber)
		return "\(discNumberString)-\(trackNumberString)" // That's a hyphen.
	}
	
	final func trackNumberFormatted() -> String {
		return (albumTrackNumber == Self.unknownTrackNumber)
		? Self.unknownTrackNumberPlaceholder
		: String(albumTrackNumber)
	}
	
}
