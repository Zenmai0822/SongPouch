//
//  Sim_SongInfo.swift
//  LavaRock
//
//  Created by h on 2022-06-30.
//

#if targetEnvironment(simulator)
import MediaPlayer
import OSLog

enum Sim_AlbumIDDispenser {
	private static var nextAvailable = 1
	static func takeNumber() -> AlbumID {
		let result = AlbumID(nextAvailable)
		nextAvailable += 1
		return result
	}
}
private enum Sim_SongIDDispenser {
	private static var nextAvailable = 1
	static func takeNumber() -> SongID {
		let result = SongID(nextAvailable)
		nextAvailable += 1
		return result
	}
}
struct Sim_SongInfo: SongInfo {
	// `SongInfo`
	
	let albumID: AlbumID
	let songID: SongID
	
	let composerOnDisk: String
	let albumArtistOnDisk: String?
	let albumTitleOnDisk: String?
	
	let discCountOnDisk: Int
	let discNumberOnDisk: Int
	let trackNumberOnDisk: Int
	static let unknownTrackNumber = MPMediaItem.unknownTrackNumber
	
	let titleOnDisk: String?
	let artistOnDisk: String?
	
	let dateAddedOnDisk: Date
	let releaseDateOnDisk: Date?
	
	func coverArt(largerThanOrEqualToSizeInPoints sizeInPoints: CGSize) -> UIImage? {
		let signposter = OSSignposter()
		let state = signposter.beginInterval("Sim: draw cover art")
		defer {
			signposter.endInterval("Sim: draw cover art", state)
		}
		guard let fileName = coverArtFileName else {
			return nil
		}
		return UIImage(named: fileName)
	}
	
	private let coverArtFileName: String?
}
extension Sim_SongInfo {
	static var dict: [SongID: Self] = [:]
	
	init(
		albumID: AlbumID,
		composerOnDisk: String,
		albumArtistOnDisk: String?,
		albumTitleOnDisk: String?,
		coverArtFileName: String?,
		discCountOnDisk: Int,
		discNumberOnDisk: Int,
		trackNumberOnDisk: Int,
		titleOnDisk: String?,
		artistOnDisk: String?,
		dateAddedOnDisk: Date,
		releaseDateOnDisk: Date?
	) {
		// Memberwise initializer
		self.init(
			albumID: albumID,
			songID: Sim_SongIDDispenser.takeNumber(),
			composerOnDisk: composerOnDisk,
			albumArtistOnDisk: albumArtistOnDisk,
			albumTitleOnDisk: albumTitleOnDisk,
			discCountOnDisk: discCountOnDisk,
			discNumberOnDisk: discNumberOnDisk,
			trackNumberOnDisk: trackNumberOnDisk,
			titleOnDisk: titleOnDisk,
			artistOnDisk: artistOnDisk,
			dateAddedOnDisk: dateAddedOnDisk,
			releaseDateOnDisk: releaseDateOnDisk,
			coverArtFileName: coverArtFileName
		)
		
		Self.dict[self.songID] = self
	}
}
#endif
