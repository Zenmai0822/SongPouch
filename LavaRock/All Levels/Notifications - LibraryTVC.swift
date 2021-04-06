//
//  Notifications - LibraryTVC.swift
//  LavaRock
//
//  Created by h on 2020-08-29.
//

import UIKit
import MediaPlayer
import CoreData

extension LibraryTVC {
	
	// MARK: - Setup and Teardown
	
	// Subclasses that override this method should call super (this implementation) at the beginning of the override.
	@objc func beginObservingNotifications() {
		NotificationCenter.default.removeObserver(self)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(didObserveLRDidChangeAccentColor),
			name: Notification.Name.LRDidChangeAccentColor,
			object: nil)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(didObserveLRDidSaveChangesFromMusicLibrary),
			name: Notification.Name.LRDidSaveChangesFromMusicLibrary,
			object: nil)
		
		guard MPMediaLibrary.authorizationStatus() == .authorized else { return }
		
//		NotificationCenter.default.addObserver(
//			self,
//			selector: #selector(didObserveLRMediaLibraryDidChange),
//			name: Notification.Name.LRMediaLibraryDidChange,
//			object: nil)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(didObservePossiblePlaybackStateChange),
			name: UIApplication.didBecomeActiveNotification,
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(didObservePossiblePlaybackStateChange),
			name: Notification.Name.MPMusicPlayerControllerPlaybackStateDidChange,
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(didObservePossiblePlaybackStateChange),
			name: Notification.Name.MPMusicPlayerControllerNowPlayingItemDidChange,
			object: nil)
	}
	
	final func endObservingNotifications() {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Responding
	
	@objc private func didObserveLRDidChangeAccentColor() {
		tableView.reloadData()
	}
	
//	@objc private func didObserveLRMediaLibraryDidChange() {
//		isEitherLoadingOrUpdating = true // Triggers a property observer that sets the "Loading…" state and imports changes
//	}
	
	@objc private func didObserveLRDidSaveChangesFromMusicLibrary() {
		PlayerControllerManager.refreshCurrentSong() // Call this from here, not from within PlayerControllerManager, because this instance needs to guarantee that this has been done before it continues.
		refreshToReflectMusicLibrary()
	}
	
	@objc private func didObservePossiblePlaybackStateChange() {
		PlayerControllerManager.refreshCurrentSong() // Call this from here, not from within PlayerControllerManager, because this instance needs to guarantee that this has been done before it continues.
		refreshToReflectPlaybackState()
	}
	
	// MARK: - After Possible Playback State Change
	
	// Subclasses that show a "now playing" indicator should override this method, call super (this implementation), and update that indicator.
	@objc func refreshToReflectPlaybackState() {
		// We want every LibraryTVC to have its playback toolbar refreshed before it appears. This tells all LibraryTVCs to refresh, even if they aren't onscreen. This works; it's just unusual.
		refreshBarButtons()
	}
	
	// LibraryTVC itself doesn't call this, but its subclasses might want to.
	final func refreshNowPlayingIndicators(
		isItemNowPlayingDeterminer: (IndexPath) -> Bool
	) {
		for indexPath in tableView.indexPathsForRowsIn(
			section: 0,
			firstRow: numberOfRowsAboveLibraryItems)
		{
			guard var cell = tableView.cellForRow(at: indexPath) as? NowPlayingIndicator else { continue }
			let isItemNowPlaying = isItemNowPlayingDeterminer(indexPath)
			let indicator = PlayerControllerManager.nowPlayingIndicator(
				isItemNowPlaying: isItemNowPlaying)
			cell.applyNowPlayingIndicator(indicator)
		}
	}
	
	// MARK: - After Importing Changes from Music Library
	
	private func refreshToReflectMusicLibrary() {
		refreshToReflectPlaybackState() // Do this even for views that aren't visible, so that when we reveal them by swiping back, the "now playing" indicators are already updated.
		refreshDataAndViewsWhenVisible()
	}
	
	// MARK: Refreshing Data and Views
	
	final func refreshDataAndViewsWhenVisible() {
		if view.window == nil {
			shouldRefreshDataAndViewsOnNextViewDidAppear = true
		} else {
			refreshDataAndViews()
		}
	}
	
	final func refreshDataAndViews() {
		let refreshedItems = sectionOfLibraryItems.fetchedItems()
		willRefreshDataAndViews(toShow: refreshedItems)
		
		guard shouldContinueAfterWillRefreshDataAndViews() else { return }
		
		isEitherLoadingOrUpdating = false
		refreshTableView(
			section: 0,
			onscreenItems: sectionOfLibraryItems.items,
			refreshedItems: refreshedItems,
			completion: {
				self.refreshData() // refreshData() includes tableView.reloadData(), which includes tableView(_:numberOfRowsInSection:), which includes refreshBarButtons(), which includes refreshPlaybackToolbarButtons(), which we need to call at some point before our work here is done.
			})
//		refreshAndSetBarButtons(animated: false) // Revert spinner back to Edit button
	}
	
	/*
	Easy to override. You should call super (this implementation) at the end of your override.
	You might be in the middle of a content-dependent task when we need to refresh. Here are all of them:
	- Sort options (LibraryTVC)
	- "Rename Collection" dialog (CollectionsTVC)
	- "Move Albums" sheet (CollectionsTVC, AlbumsTVC when in "moving Albums" mode)
	- "New Collection" dialog (CollectionsTVC when in "moving Albums" mode)
	- Song actions (SongsTVC)
	- (Editing mode is a special state, but refreshing in editing mode is fine (with no other "breath-holding modes" presented).)
	Subclasses that offer those tasks should override this method and cancel those tasks. For more polish, only cancel those tasks if the refresh will change the content that those actions apply to. Typically, that's when refreshedItems is different from sectionOfLibraryItems.items.
	*/
	@objc func willRefreshDataAndViews(
		toShow refreshedItems: [NSManagedObject]
	) {
		// Only dismiss modal view controllers if sectionOfLibraryItems.items will change during the refresh?
//		print(presentedViewController)
		let shouldNotDismissAllModalViewControllers =
			(presentedViewController as? UINavigationController)?.viewControllers.first is OptionsTVC
		if !shouldNotDismissAllModalViewControllers {
			view.window?.rootViewController?.dismiss(
				animated: true,
				completion: didDismissAllModalViewControllers)
		}
	}
	
	// Easy to override. You should call super (this implementation) in your override.
	@objc func didDismissAllModalViewControllers() {
	}
	
	// Easy to override. You should not call super (this implementation) in your override.
	@objc func shouldContinueAfterWillRefreshDataAndViews() -> Bool {
		return true
	}
	
	// MARK: Refreshing Table View
	
	// Easy to plug arguments into. You can call this on its own, separate from refreshDataAndViews().
	// Note: Even though this method is easy to plug arguments into, it (currently) has side effects: it replaces sectionOfLibraryItems.items with the refreshedItems that you pass in.
	private func refreshTableView(
		section: Int,
		onscreenItems: [NSManagedObject],
		refreshedItems: [NSManagedObject],
		completion: (() -> ())?
	) {
		guard !refreshedItems.isEmpty else {
			deleteAllRowsThenExit()
			return
		}
		
		var indexPathsToMove = [(IndexPath, IndexPath)]()
		var indexPathsToInsert = [IndexPath]()
		
		for indexOfRefreshedItem in 0 ..< refreshedItems.count {
			let refreshedItem = refreshedItems[indexOfRefreshedItem]
			if let indexOfOnscreenItem = onscreenItems.firstIndex(where: { onscreenItem in
				onscreenItem.objectID == refreshedItem.objectID
			}) { // This item is already onscreen, and we still want it onscreen. If necessary, we'll move it. Later, if necessary, we'll update it.
				let startingIndexPath = indexPathFor(
					indexOfLibraryItem: indexOfOnscreenItem,
					indexOfSectionOfLibraryItem: section)
				let endingIndexPath = indexPathFor(
					indexOfLibraryItem: indexOfRefreshedItem,
					indexOfSectionOfLibraryItem: section)
				indexPathsToMove.append(
					(startingIndexPath, endingIndexPath))
				
			} else { // This item isn't onscreen yet, but we want it onscreen, so we'll have to add it.
				indexPathsToInsert.append(
					indexPathFor(
						indexOfLibraryItem: indexOfRefreshedItem,
						indexOfSectionOfLibraryItem: section)
				)
			}
		}
		
		var indexPathsToDelete = [IndexPath]()
		
		for indexOfOnscreenItem in 0 ..< onscreenItems.count {
			let onscreenItem = onscreenItems[indexOfOnscreenItem]
			if let _ = refreshedItems.firstIndex(where: { refreshedItem in
				refreshedItem.objectID == onscreenItem.objectID
			})  {
				continue // to the next onscreenItem
			} else {
				indexPathsToDelete.append(
					indexPathFor(
						indexOfLibraryItem: indexOfOnscreenItem,
						indexOfSectionOfLibraryItem: section)
				)
			}
		}
		
		sectionOfLibraryItems.items = refreshedItems
		
		isAnimatingDuringRefreshTableView += 1
		tableView.performBatchUpdates {
			tableView.deleteRows(at: indexPathsToDelete, with: .middle)
			tableView.insertRows(at: indexPathsToInsert, with: .middle)
			for (startingIndexPath, endingIndexPath) in indexPathsToMove {
				guard startingIndexPath != endingIndexPath else { continue } // (Might) prevent the table view from unnecessarily scrolling the top row to the top of the screen.
				tableView.moveRow(at: startingIndexPath, to: endingIndexPath)
			}
		} completion: { _ in
			self.isAnimatingDuringRefreshTableView -= 1
			if self.isAnimatingDuringRefreshTableView == 0 { // If we execute multiple refreshes quickly, executions after the first one can beat the first one to the completion closure, because they don't have to animate anything in performBatchUpdates. This line of code lets us wait for the animations to finish before we execute the completion closure.
				completion?()
			}
		}
	}
	
	private func deleteAllRowsThenExit() {
		var allIndexPaths = [IndexPath]()
		for section in 0 ..< tableView.numberOfSections {
			let allIndexPathsInSection =
				tableView.indexPathsForRowsIn(section: section, firstRow: 0)
			allIndexPaths.append(contentsOf: allIndexPathsInSection)
		}
		sectionOfLibraryItems.items.removeAll()
		tableView.performBatchUpdates {
			tableView.deleteRows(at: allIndexPaths, with: .middle)
		} completion: { _ in
			guard !(self is CollectionsTVC) else { return }
			self.performSegue(withIdentifier: "Removed All Contents", sender: self)
		}
	}
	
	// MARK: Refreshing Data
	
	@objc private func refreshData() {
		guard !sectionOfLibraryItems.items.isEmpty else { return }
		refreshContainers()
		refreshTableViewRowContents()
	}
	
	// Subclasses that show information that depends on sectionOfLibraryItems.container in their views should subclass this method, call super (this implementation), and then update their views.
	@objc func refreshContainers() {
		sectionOfLibraryItems.refreshContainer()
	}
	
	/*
	This is the final step in refreshTableView. The earlier steps delete, insert, and move rows as necessary (with animations), and update sectionOfLibraryItems.items. This method updates the data within each row, which might be outdated: for example, songs' titles and albums' release dates.
	The simplest way to do this is to just call tableView.reloadData(). Infamously, that has no animation, but we actually animated the deletes, inserts, and moves by ourselves earlier. All reloadData() does here is update the data within each row without an animation, which usually looks okay.
	You should override this method if you want to add animations when refreshing the contents of any part of table view. For example, if it looks jarring to change some artwork without an animation, you might want to refresh that artwork with a fade animation, but leave the other rows to update without animations. The hard part is that to prevent unnecessary animations when the content hasn't changed, you'll have to detect the existing content in each row.
	*/
	@objc private func refreshTableViewRowContents() {
		tableView.reloadData()
	}
	
}
