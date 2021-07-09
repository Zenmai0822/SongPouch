//
//  MusicLibraryManager.swift
//  LavaRock
//
//  Created by h on 2020-08-10.
//

import MediaPlayer
import OSLog

final class MusicLibraryManager { // This is a class and not a struct because it should end observing notifications in a deinitializer.
	
	// MARK: - Properties
	
	// Constants
	static let shared = MusicLibraryManager()
	let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	// Variables
	private var library: MPMediaLibrary?
	
	// MARK: - Setup and Teardown
	
	private init() { }
	
	final func setUpAndImportChanges() {
		guard MPMediaLibrary.authorizationStatus() == .authorized else { return }
		
		library = MPMediaLibrary.default()
		importChanges()
		beginGeneratingNotifications()
	}
	
	deinit {
		endGeneratingNotifications()
	}
	
	// MARK: - Notifications
	
	private func beginGeneratingNotifications() {
		guard MPMediaLibrary.authorizationStatus() == .authorized else { return }
		
		NotificationCenter.default.removeObserver(self)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(mediaLibraryDidChange),
			name: Notification.Name.MPMediaLibraryDidChange,
			object: nil)
		library?.beginGeneratingLibraryChangeNotifications()
	}
	
	private func endGeneratingNotifications() {
		NotificationCenter.default.removeObserver(self)
		
		library?.endGeneratingLibraryChangeNotifications()
	}
	
	// MARK: Responding
	
	@objc private func mediaLibraryDidChange() {
		importChanges()
	}
	
}
