//
//  LibraryTVC.swift
//  LavaRock
//
//  Created by h on 2020-04-15.
//  Copyright © 2020 h. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer

class LibraryTVC:
	UITableViewController//,
	//NSFetchedResultsControllerDelegate
{
	
	// MARK: Properties
	
	// "Constants" that subclasses should customize
	var coreDataEntityName = "Collection"
	var containerOfData: NSManagedObject?
	
	// "Constants" that subclasses can optionally customize
	var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // Replace this with a child managed object context when in "moving albums" mode.
	var navigationItemButtonsNotEditMode = [UIBarButtonItem]()
	var navigationItemButtonsEditModeOnly = [UIBarButtonItem]()
	var sortOptions = [String]()
	
	// "Constants" that subclasses should not change
	let mediaPlayerManager = (UIApplication.shared.delegate as! AppDelegate).mediaPlayerManager
	let cellReuseIdentifier = "Cell"
	lazy var floatToTopButton = UIBarButtonItem(
		image: UIImage(systemName: "arrow.up.to.line.alt"), // Needs VoiceOver hint
		style: .plain,
		target: self,
		action: #selector(moveSelectedItemsToTop))
	lazy var sortButton = UIBarButtonItem(
		image: UIImage(systemName: "arrow.up.arrow.down"), // Needs VoiceOver hint
		style: .plain,
		target: self,
		action: #selector(showSortOptions))
	lazy var cancelMoveAlbumsButton = UIBarButtonItem(
		barButtonSystemItem: .cancel,
		target: self,
		action: #selector(cancelMoveAlbums))
//	var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
	
	// Variables
	var activeLibraryItems = [NSManagedObject]() { // The truth for the order of items is their order in activeLibraryItems, because the table view follows activeLibraryItems; not the "index" attribute of each NSManagedObject.
		didSet {
			didSetActiveLibraryItems()
		}
	}
	lazy var coreDataFetchRequest: NSFetchRequest<NSManagedObject> = {
		let request = NSFetchRequest<NSManagedObject>(entityName: coreDataEntityName)
		request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
		return request
	}()
	var shouldRespondToWillSaveChangesFromAppleMusicLibraryNotifications = true
	var shouldRespondToNextManagedObjectContextDidSaveNotification = false
//	var isUserCurrentlyMovingRowManually = false
	
	// MARK: Property Observers
	
	func didSetActiveLibraryItems() {
		for index in 0..<self.activeLibraryItems.count {
			activeLibraryItems[index].setValue(index, forKey: "index")
		}
	}
	
	// MARK: - Setup
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setUpUI()
		loadSavedLibraryItems()
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(didObserve(_:)),
			name: Notification.Name.LRWillSaveChangesFromAppleMusicLibrary,
			object: nil)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(didObserve(_:)),
			name: Notification.Name.NSManagedObjectContextDidSave,
			object: managedObjectContext)
	}
	
	func setUpUI() {
		navigationItem.leftBarButtonItems = navigationItemButtonsNotEditMode
		navigationItem.rightBarButtonItem = editButtonItem
		navigationItemButtonsEditModeOnly = [floatToTopButton]
		
		refreshNavigationBarButtons()
		
		tableView.tableFooterView = UIView() // Removes the blank cells after the content ends. You can also drag in an empty View below the table view in the storyboard, but that also removes the separator below the last cell.
	}
	
	// MARK: Loading Data
	
	func loadSavedLibraryItems() {
		if let containerOfData = containerOfData {
			coreDataFetchRequest.predicate = NSPredicate(format: "container == %@", containerOfData)
		}
		
//		updateFetchedResultsController()
		
		activeLibraryItems = managedObjectContext.objectsFetched(for: coreDataFetchRequest)
	}
	
//	func updateFetchedResultsController() {
//		NSFetchedResultsController<NSManagedObject>.deleteCache(withName: fetchedResultsController?.cacheName)
//
//		if let containerOfData = containerOfData {
//			coreDataFetchRequest.predicate = NSPredicate(format: "container == %@", containerOfData)
//		}
//		fetchedResultsController = NSFetchedResultsController(
//			fetchRequest: coreDataFetchRequest,
//			managedObjectContext: managedObjectContext,
//			sectionNameKeyPath: nil,
//			cacheName: nil
//		)
//		fetchedResultsController?.delegate = self
//
//		do {
//			try fetchedResultsController?.performFetch()
//		} catch {
//			fatalError("Initialized an NSFetchedResultsController, but couldn't fetch objects.")
//		}
//	}
	
	// MARK: - Teardown
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Table View
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// You need to accommodate 2 special cases:
		// 1. When the user hasn't allowed access to Apple Music, use the "Allow Access to Apple Music" cell as a button.
		// 2. When there are no items, set the "Add some songs to the Apple Music app." placeholder cell to the background view.
		refreshNavigationBarButtons()
		switch MPMediaLibrary.authorizationStatus() {
		case .authorized:
			// This logic, for setting the "no items" placeholder, should be in numberOfRowsInSection, not in numberOfSections.
			// - If you put it in numberOfSections, VoiceOver moves focus from the tab bar directly to the navigation bar title, skipping over the placeholder. (It will move focus to the placeholder if you tap there, but then you won't be able to move focus out until you tap elsewhere.)
			// - If you put it in numberOfRowsInSection, VoiceOver move focus from the tab bar to the placeholder, then to the navigation bar title, as expected.
			
//			guard let numberOfItems = fetchedResultsController?.sections?[section].numberOfObjects else {
//				return 0
//			}
			
//			if numberOfItems > 0 {
			if activeLibraryItems.count > 0 {
				tableView.backgroundView = nil
//				return numberOfItems
				return activeLibraryItems.count
			} else {
				let noItemsView = tableView.dequeueReusableCell(withIdentifier: "No Items Cell")! // Every subclass needs a placeholder cell in the storyboard with this reuse identifier.
				tableView.backgroundView = noItemsView
				return 0
			}
		default:
			tableView.backgroundView = nil
			return 1 // "Allow Access" cell
		}
    }
	
	// All subclasses should override this.
	// Also, all subclasses should check the authorization status for the Apple Music library, and if the user hasn't granted authorization yet, they should call super (this implementation) to return the "Allow Access" cell.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard MPMediaLibrary.authorizationStatus() == .authorized else {
			return allowAccessCell(for: indexPath)
		}
		return UITableViewCell()
    }
	
	func allowAccessCell(for indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Allow Access Cell", for: indexPath) // We need a copy of this cell in every scene in the storyboard that might use it.
		if #available(iOS 14.0, *) {
			var configuration = UIListContentConfiguration.cell()
			configuration.text = "Allow Access to Apple Music"
			configuration.textProperties.color = view.window!.tintColor
			cell.contentConfiguration = configuration
		} else { // iOS 13 and earlier
			cell.textLabel?.textColor = view.window?.tintColor
		}
		return cell
	}
	
	// MARK: Fetched Results Controller Delegate
	
	/*
	func controller(
		_ controller: NSFetchedResultsController<NSFetchRequestResult>,
		didChange anObject: Any,
		at indexPath: IndexPath?,
		for type: NSFetchedResultsChangeType,
		newIndexPath: IndexPath?
	) {
//		guard !isUserCurrentlyMovingRowManually else {
//			fatalError("The NSFetchedResultsController reported that an item should be moved automatically while the user was already moving an item manually.")
//		} // What if the controller reports that an object moved in the data layer, and the user is currently moving an object manually?
		
		print("NSFetchedResultsController has detected a change to the object: \(anObject)")
		print("It thinks the type of change should be: \(type)")
	}
	*/
	
	// MARK: - Events
	
	@objc func didObserve(_ notification: Notification) {
		print("Observed notification: \(notification.name)")
		switch notification.name {
		case .LRWillSaveChangesFromAppleMusicLibrary:
			willSaveChangesFromAppleMusicLibrary(notification)
		case .NSManagedObjectContextDidSave:
			managedObjectContextDidSave(notification)
		default:
			print("… but the app is not set to do anything after observing that notification.")
		}
	}
	
	func willSaveChangesFromAppleMusicLibrary(_ notification: Notification) {
		guard shouldRespondToWillSaveChangesFromAppleMusicLibraryNotifications else { return }
		shouldRespondToNextManagedObjectContextDidSaveNotification = true
	}
	
	@objc func managedObjectContextDidSave(_ notification: Notification) {
		print("The class “\(Self.self)” should override managedObjectContextDidSave(_:). We would call it at this point.")
	}
	
	func refreshNavigationBarButtons() {
		if
			MPMediaLibrary.authorizationStatus() == .authorized,
//			(fetchedResultsController?.fetchedObjects?.count ?? 0) >= 1
			activeLibraryItems.count >= 1
		{
			editButtonItem.isEnabled = true
		} else {
			editButtonItem.isEnabled = false
		}
		
		if isEditing {
			floatToTopButton.isEnabled = shouldAllowFloatingToTop(indexPathsForSelectedRows: tableView.indexPathsForSelectedRows)
			sortButton.isEnabled = shouldAllowSorting()
			navigationItem.setLeftBarButtonItems(navigationItemButtonsEditModeOnly, animated: true)
		} else {
			navigationItem.setLeftBarButtonItems(navigationItemButtonsNotEditMode, animated: true)
		}
	}
	
	@objc func cancelMoveAlbums() {
		dismiss(animated: true, completion: nil)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		switch MPMediaLibrary.authorizationStatus() {
		case .authorized:
			break
		case .notDetermined: // The golden opportunity.
			MPMediaLibrary.requestAuthorization() { newStatus in // Fires the alert asking the user for access.
				switch newStatus {
				case .authorized:
					DispatchQueue.main.async {
						self.shouldRespondToWillSaveChangesFromAppleMusicLibraryNotifications = false
						self.mediaPlayerManager.shouldNextMergeBeSynchronous = true
						self.viewDidLoad() // Includes mediaPlayerManager.setUpLibraryIfAuthorized(), which includes merging changes from the Apple Music library.
						switch self.tableView(tableView, numberOfRowsInSection: 0) { // tableView.numberOfRows might not be up to date yet. Call the actual UITableViewDelegate method.
						case 0:
							tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
						case 1:
							tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .middle)
						default:
							tableView.performBatchUpdates({
								tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .middle)
								tableView.insertRows(at: self.indexPathsEnumeratedIn(section: 0, firstRow: 1, lastRow: self.tableView(tableView, numberOfRowsInSection: 0) - 1), with: .middle)
							}, completion: nil)
						}
						self.shouldRespondToWillSaveChangesFromAppleMusicLibraryNotifications = true
					}
				default:
					DispatchQueue.main.async { self.tableView.deselectRow(at: indexPath, animated: true) }
				}
			}
		default: // Denied or restricted.
			let settingsURL = URL(string: UIApplication.openSettingsURLString)!
			UIApplication.shared.open(settingsURL)
			tableView.deselectRow(at: indexPath, animated: true)
		}
		
		if isEditing {
			refreshNavigationBarButtons()
		}
		
	}
	
	override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		refreshNavigationBarButtons()
	}
	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		return !isEditing
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if
			segue.identifier == "Drill Down in Library",
			let destination = segue.destination as? LibraryTVC,
			let selectedIndexPath = tableView.indexPathForSelectedRow//,
//			let selectedItem = fetchedResultsController?.object(at: selectedIndexPath)
		{
			let selectedItem = activeLibraryItems[selectedIndexPath.row]
			destination.containerOfData = selectedItem
			destination.managedObjectContext = managedObjectContext
		}
		
		super.prepare(for: segue, sender: sender)
	}
	
}
