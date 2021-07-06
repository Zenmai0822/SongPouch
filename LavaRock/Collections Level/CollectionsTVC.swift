//
//  CollectionsTVC.swift
//  LavaRock
//
//  Created by h on 2020-05-04.
//  Copyright © 2020 h. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer

final class CollectionsTVC:
	LibraryTVC,
	AlbumMover
{
	
	// MARK: - Types
	
	enum ContentState {
		case allowAccess
		case loading
		case justFinishedLoading
		case normal
	}
	
	// MARK: - Properties
	
	// "Constants"
	@IBOutlet private var optionsButton: UIBarButtonItem!
	private lazy var combineButton = UIBarButtonItem(
		title: "Combine", // TO DO: Localize
		style: .plain,
		target: self,
		action: #selector(presentDialogToCombineSelectedCollections))
	private lazy var makeNewCollectionButton = UIBarButtonItem(
		barButtonSystemItem: .add,
		target: self,
		action: #selector(presentDialogToMakeNewCollection))
	
	// Variables
	var didJustFinishLoading = false
	var previousSectionOfCollections: SectionOfLibraryItems?
	
	// MARK: "Moving Albums" Mode
	
	// Variables
	var albumMoverClipboard: AlbumMoverClipboard?
	var didMoveAlbums = false
	
	// MARK: - Content State
	
	final func contentState() -> ContentState {
		if MPMediaLibrary.authorizationStatus() != .authorized {
			return .allowAccess
		}
		if didJustFinishLoading { // You must check didJustFinishLoading before checking isImportingChanges.
			return .justFinishedLoading
		}
		if
			isImportingChanges,
			sectionOfLibraryItems.items.isEmpty
		{
			return .loading
		}
		return .normal
	}
	
	final func deleteAllRowsIfFinishedLoading() {
		if contentState() == .loading {
			didJustFinishLoading = true // contentState() is now .justFinishedLoading
			refreshToReflectContentState(completion: nil)
			didJustFinishLoading = false
		}
	}
	
	private func refreshToReflectContentState(
		completion: (() -> ())?
	) {
		let oldIndexPaths = tableView.allIndexPaths()
		switch contentState() {
		case .allowAccess /*Currently unused*/, .loading:
			let indexPathsToKeep = [IndexPath(row: 0, section: 0)]
			let updateTableView: () -> () = {
				switch oldIndexPaths.count {
				case 0: // Launch -> "Loading…"
					return {
						self.tableView.insertRows(at: indexPathsToKeep, with: .fade)
					}
				case 1: // "Allow Access" -> "Loading…"
					return {
						self.tableView.reloadRows(at: indexPathsToKeep, with: .fade)
					}
				default: // Currently unused
					let indexPathsToDelete = Array(oldIndexPaths.dropFirst())
					return {
						self.tableView.deleteRows(at: indexPathsToDelete, with: .fade)
						self.tableView.reloadRows(at: indexPathsToKeep, with: .fade)
					}
				}
			}()
			tableView.performBatchUpdates {
				updateTableView()
			} completion: { _ in
				completion?()
			}
		case .justFinishedLoading: // "Loading…" -> empty
			tableView.performBatchUpdates {
				tableView.deleteRows(at: oldIndexPaths, with: .middle)
			} completion: { _ in
				completion?()
			}
		case .normal: // Importing changes with existing Collections
			completion?()
		}
	}
	
	// MARK: - Setup
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		sortOptionGroups = [
			[.title],
			[.reverse]
		]
	}
	
	final override func viewDidLoad() {
		super.viewDidLoad()
		
		if albumMoverClipboard != nil {
		} else {
			DispatchQueue.main.async {
				self.integrateWithBuiltInMusicApp()
			}
		}
	}
	
	// Similar to viewDidLoad().
	final func didReceiveAuthorizationForMusicLibrary() {
		setUp()
		
		integrateWithBuiltInMusicApp()
	}
	
	private func integrateWithBuiltInMusicApp() {
		guard MPMediaLibrary.authorizationStatus() == .authorized else { return }
		
		isImportingChanges = true // contentState() is now .loading or .normal (updating)
		refreshToReflectContentState(completion: {
			MusicLibraryManager.shared.setUpLibraryAndImportChanges() // You must finish LibraryTVC's beginObservingNotifications() before this, because we need to observe the notification after the import completes.
			PlayerManager.setUp() // This actually doesn't trigger refreshing the playback toolbar; refreshing after importing changes (above) does.
		})
	}
	
	// MARK: Setting Up UI
	
	final override func setUpUI() {
		// Choose our buttons for the navigation bar and toolbar before calling super, because super sets those buttons.
		if albumMoverClipboard != nil {
			topLeftButtonsInViewingMode = []
			topRightButtons = [cancelMoveAlbumsButton]
			bottomButtonsInViewingMode = [
				.flexibleSpac3(),
				makeNewCollectionButton,
				.flexibleSpac3(),
			]
		} else {
			topLeftButtonsInViewingMode = [optionsButton]
		}
		
		super.setUpUI()
		
		if let albumMoverClipboard = albumMoverClipboard {
			navigationItem.prompt = albumMoverClipboard.navigationItemPrompt
		} else {
			bottomButtonsInEditingMode = [
//				combineButton,
//				.flexibleSpac3(),
				
				sortButton,
				.flexibleSpac3(),
				
//				moveToTopOrBottomButton,
				floatToTopButton,
				.flexibleSpac3(),
				sinkToBottomButton,
			]
		}
	}
	
	// MARK: Setup Events
	
	@IBAction func unwindToCollectionsFromEmptyCollection(_ unwindSegue: UIStoryboardSegue) {
	}
	
	final override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if albumMoverClipboard != nil {
		} else {
			if didMoveAlbums {
				// Replace this with refreshToReflectMusicLibrary()?
				refreshToReflectPlaybackState()
				refreshDataAndViewsWhenVisible() // Note: This re-animates adding the Collections we made while moving Albums, even though we already saw them get added in the "move Albums to…" sheet.
				
				didMoveAlbums = false
			}
		}
	}
	
	final override func viewDidAppear(_ animated: Bool) {
		if albumMoverClipboard != nil {
			deleteEmptyNewCollection()
		}
		
		super.viewDidAppear(animated)
	}
	
	// MARK: - Refreshing Buttons
	
	final override func refreshBarButtons() {
		super.refreshBarButtons()
		
		if isEditing {
			combineButton.isEnabled = allowsCombine()
		}
	}
	
	// MARK: - Navigation
	
	final override func prepare(
		for segue: UIStoryboardSegue,
		sender: Any?
	) {
		if
			segue.identifier == "Drill Down in Library",
			let albumsTVC = segue.destination as? AlbumsTVC
		{
			albumsTVC.albumMoverClipboard = albumMoverClipboard
		}
		
		super.prepare(for: segue, sender: sender)
	}
	
}
