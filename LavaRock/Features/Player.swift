//
//  Player.swift
//  LavaRock
//
//  Created by h on 2020-11-04.
//

import MediaPlayer
import CoreData

@MainActor
final class Player { // This is a class and not a struct because it should end observing notifications in a deinitializer.
	private init() {}
	static let shared = Player()
	
	final func addReflector(weaklyReferencing reflector: PlayerReflecting) {
		let weakReflector = Weak(reflector)
		reflectors.append(weakReflector)
	}
	
	private(set) var player: MPMusicPlayerController? = nil
	
	final func setUp() {
		guard MPMediaLibrary.authorizationStatus() == .authorized else { return }
		
		player?.endGeneratingPlaybackNotifications()
		if Enabling.playerScreen {
			player = .applicationQueuePlayer
		} else {
			player = .systemMusicPlayer
		}
		player?.beginGeneratingPlaybackNotifications()
		
		reflectors.removeAll { $0.referencee == nil }
		reflectors.forEach {
			// Because before anyone called this method, `player` was `nil`.
			$0.referencee?.beginReflectingPlaybackState()
		}
	}
	
	final func songInPlayer(context: NSManagedObjectContext) -> Song? {
		guard let nowPlayingItem = player?.nowPlayingItem else {
			return nil
		}
		
		let currentMPSongID = MPSongID(bitPattern: nowPlayingItem.persistentID)
		let songsFetchRequest = Song.fetchRequest()
		songsFetchRequest.predicate = NSPredicate(
			format: "persistentID == %lld",
			currentMPSongID)
		let songsInPlayer = context.objectsFetched(for: songsFetchRequest)
		
		guard
			songsInPlayer.count == 1,
			let song = songsInPlayer.first
		else {
			return nil
		}
		return song
	}
	
	// MARK: - Private
	
	private var reflectors: [Weak<PlayerReflecting>] = []
	
	deinit {
		player?.endGeneratingPlaybackNotifications()
	}
}
