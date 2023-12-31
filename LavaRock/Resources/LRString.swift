//
//  LRString.swift
//  LavaRock
//
//  Created by h on 2020-12-05.
//

import Foundation

// Keeping these keys in one place helps us keep them unique.
// It also helps us use the same text in multiple places if appropriate.
enum LRString {
	// Don’t pass arguments other than strings to the Foundation function `NSLocalizedString`, because otherwise, when you choose “Export Localizations…”, Xcode won’t include those calls.
	
	// MARK: - WITHOUT VARIABLES
	
	// MARK: Standard
	
	static let cancel = NSLocalizedString("Cancel", comment: "Button")
	static let done = NSLocalizedString("Done", comment: "Button")
	static let more = NSLocalizedString("More", comment: "Button")
	
	static let emDash = NSLocalizedString("—", comment: "Em dash, for missing data")
	static let ellipsis = NSLocalizedString("…", comment: "Indicator for truncated text")
	static let interpunct = NSLocalizedString("·", comment: "Interpunct, for separating pieces of information")
	static let tilde = NSLocalizedString("~", comment: "Default title for a new crate")
	
	// MARK: Albums
	
	static let unknownArtist = NSLocalizedString("Unknown Artist", comment: "")
	static let unknownAlbum = NSLocalizedString("Unknown Album", comment: "")
	
	// MARK: Toolbar
	
	static let repeat_ = NSLocalizedString("Repeat", comment: "Button")
	
	static let previous = NSLocalizedString("Previous", comment: "Button")
	static let restart = NSLocalizedString("Restart", comment: "Button")
	// As of iOS 16.5 RC 1, picture-in-picture videos use “Skip back 10 seconds” and “Skip forward 10 seconds”.
	static let skipBack15Seconds = NSLocalizedString("Skip back 15 seconds", comment: "Button")
	static let play = NSLocalizedString("Play", comment: "Button")
	static let pause = NSLocalizedString("Pause", comment: "Button")
	static let skipForward15Seconds = NSLocalizedString("Skip forward 15 seconds", comment: "Button")
	static let next = NSLocalizedString("Next", comment: "Button")
	
	// MARK: Now-playing icon
	
	static let nowPlaying = NSLocalizedString("Now playing", comment: "Accessibility label")
	static let paused = NSLocalizedString("Paused", comment: "Accessibility label")
	
	// MARK: Editing
	
	static let sort = NSLocalizedString("Sort", comment: "Button")
	static let random = NSLocalizedString("Random", comment: "Sort option")
	static let reverse = NSLocalizedString("Reverse", comment: "Sort option")
	
	static let moveToTop = NSLocalizedString("Move to top", comment: "Accessibility label, button")
	static let moveToBottom = NSLocalizedString("Move to bottom", comment: "Accessibility label, button")
	
	// MARK: - Crates view
	
	static let welcome_title = NSLocalizedString("Hi, Let’s Play", comment: "Placeholder when no access to Apple Music; title")
	static let welcome_subtitle = NSLocalizedString("…your Apple Music library!", comment: "Placeholder when no access to Apple Music; subtitle")
	static let allowAccess = NSLocalizedString("Allow Access", comment: "Button")
	
	static let emptyLibrary_title = NSLocalizedString("Nothing to Hear Here", comment: "Placeholder when library is empty; title")
	static let emptyLibrary_subtitle = NSLocalizedString("Your library’s empty.", comment: "Placeholder when library is empty; subtitle")
	static let emptyLibrary_button = NSLocalizedString("Add Music", comment: "Button")
	
	static let rename = NSLocalizedString("Rename", comment: "Button")
	
	static let name = NSLocalizedString("Name", comment: "The word for the title of a crate. Also a sort option.")
	
	// MARK: Albums view
	
	static let move = NSLocalizedString("Move", comment: "Button")
	
	static let newest = NSLocalizedString("Newest", comment: "Sort option")
	static let oldest = NSLocalizedString("Oldest", comment: "Sort option")
	
	// MARK: Songs view
	
	static let albumArtwork = NSLocalizedString("Album artwork", comment: "Accessibility label")
	
	static let startPlaying = NSLocalizedString("Start Playing", comment: "Button")
	static let playLast = NSLocalizedString("Play Last", comment: "Button")
	static let playRestOfAlbumLast = NSLocalizedString("Play Rest of Album Last", comment: "Button")
	
	static let trackNumber = NSLocalizedString("Track Number", comment: "Sort option")
	
	// MARK: - WITH VARIABLES, BUT NO TEXT VARIATIONS
	
	// MARK: - WITH VARIABLES AND TEXT VARIATIONS
	// (Format strings from dictionaries)
}
