//
//  Editing - CollectionsTVC.swift
//  LavaRock
//
//  Created by h on 2020-08-23.
//

import UIKit
import CoreData

extension CollectionsTVC {
	
//	override func setEditing(_ editing: Bool, animated: Bool) {
//		super.setEditing(editing, animated: animated)
//
//		refreshVoiceControlNamesForAllCells()
//	}
	
//	private func refreshVoiceControlNamesForAllCells() {
//		for indexPath in tableView.indexPathsForRows(
//			inSection: 0,
//			firstRow: numberOfRowsAboveLibraryItems)
//		{
//			guard let cell = tableView.cellForRow(at: indexPath) else { continue }
//			
//			refreshVoiceControlNames(for: cell)
//		}
//	}
	
	// MARK: - Renaming Collection
	
	// Match presentDialogToMakeNewCollection(_:).
	final func renameCollection(at indexPath: IndexPath) {
		guard let collection = libraryItem(for: indexPath) as? Collection else { return }
		
		let wasRowSelectedBeforeRenaming = tableView.indexPathsF0rSelectedRows.contains(indexPath)
		
		let dialog = UIAlertController(
			title: LocalizedString.renameCollection,
			message: nil,
			preferredStyle: .alert)
		dialog.addTextField(configurationHandler: { textField in
			// UITextField
			textField.text = collection.title
			textField.placeholder = LocalizedString.title
			textField.clearButtonMode = .whileEditing
			
			// UITextInputTraits
			textField.returnKeyType = .done
			textField.autocapitalizationType = .sentences
			textField.smartQuotesType = .yes
			textField.smartDashesType = .yes
		})
		let cancelAction = UIAlertAction(
			title: LocalizedString.cancel,
			style: .cancel,
			handler: nil)
		let saveAction = UIAlertAction(
			title: LocalizedString.save,
			style: .default,
			handler: { [self] _ in
				let rawProposedTitle = dialog.textFields?[0].text
				let newTitle = Collection.validatedTitle(from: rawProposedTitle)
				
				collection.title = newTitle
				managedObjectContext.tryToSave()
				
				tableView.reloadRows(at: [indexPath], with: .fade)
				if wasRowSelectedBeforeRenaming {
					tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
				}
			}
		)
		dialog.addAction(cancelAction)
		dialog.addAction(saveAction)
		dialog.preferredAction = saveAction
		present(dialog, animated: true)
	}
	
}
