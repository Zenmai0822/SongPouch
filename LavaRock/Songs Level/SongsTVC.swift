//
//  SongsTVC.swift
//  LavaRock
//
//  Created by h on 2020-05-04.
//  Copyright © 2020 h. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer

final class SongsTVC:
	LibraryTVC,
	NavigationItemTitleCustomizer
{
	
	// MARK: - Setup
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		entityName = "Song"
		numberOfRowsAboveLibraryItems = 2
	}
	
	// MARK: Setting Up UI
	
	final override func setUpUI() {
		super.setUpUI()
		
		refreshNavigationItemTitle()
		toolbarButtonsEditingModeOnly = [
			sortButton,
			flexibleSpaceBarButtonItem,
			floatToTopButton,
			flexibleSpaceBarButtonItem,
			sinkToBottomButton
		]
		sortOptions = [.trackNumber]
	}
	
	final func refreshNavigationItemTitle() {
		guard let containingAlbum = sectionOfLibraryItems.container as? Album else { return }
		title = containingAlbum.titleFormattedOrPlaceholder()
	}
	
}
