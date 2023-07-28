//
//  Folders - Views.swift
//  LavaRock
//
//  Created by h on 2020-11-06.
//

import UIKit
import SwiftUI

final class CreateFolderCell: UITableViewCell {
	@IBOutlet private var newFolderLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		newFolderLabel.text = LRString.newFolder
		newFolderLabel.textColor = .tintColor
		
		accessibilityTraits.formUnion(.button)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		separatorInset.right = directionalLayoutMargins.trailing
	}
}

enum FolderRowMode {
	case normal([UIAccessibilityCustomAction])
	case modal
	case modalTinted
	case modalDisabled
}
struct FolderRow: View {
	let folder: Collection
	let mode: FolderRowMode
	
	var body: some View {
		HStack {
			Text(folder.title ?? " ")
			Spacer()
			AvatarImage(
				libraryItem: folder)
			.accessibilitySortPriority(10)
		}
		.opacity({
			if case FolderRowMode.modalDisabled = mode {
				return .oneFourth
			} else {
				return 1
			}
		}())
		.accessibilityElement(children: .combine)
		.accessibilityAddTraits(.isButton)
		.accessibilityInputLabels(
			// Exclude the now-playing marker.
			[
				folder.title, // Can be `nil`
			].compacted()
		)
	}
}
final class FolderCell: UITableViewCell {
	private static let usesSwiftUI__ = 10 == 1
	
	// `AvatarDisplaying__`
	@IBOutlet var spacerSpeakerImageView: UIImageView!
	@IBOutlet var speakerImageView: UIImageView!
	
	private var rowContentAccessibilityLabel__: String? = nil
	
	@IBOutlet private var titleLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		backgroundColor_set_to_clear()
	}
	
	func configure(
		with folder: Collection,
		mode: FolderRowMode
	) {
		if Self.usesSwiftUI__ {
			contentConfiguration = UIHostingConfiguration {
				FolderRow(
					folder: folder,
					mode: mode)
			}
		} else {
			titleLabel.text = folder.title ?? " " // Don’t let this be empty. Otherwise, when we revert combining folders before `freshenLibraryItems`, the table view vertically collapses rows for deleted folders.
			contentView.layer.opacity = {
				if case FolderRowMode.modalDisabled = mode {
					return .oneFourth
				} else {
					return 1
				}
			}()
			
			rowContentAccessibilityLabel__ = titleLabel.text
			indicateAvatarStatus__(
				folder.avatarStatus()
			)
			
			// Exclude the now-playing marker.
			accessibilityUserInputLabels = [
				folder.title, // Can be `nil`
			].compacted()
		}
		
		switch mode {
			case .normal(let actions):
				backgroundColor_set_to_clear()
				
				isUserInteractionEnabled_setTrueWithAxTrait()
				accessibilityCustomActions = actions
			case .modal:
				backgroundColor_set_to_clear()
				
				isUserInteractionEnabled_setTrueWithAxTrait()
				accessibilityCustomActions = []
			case .modalTinted:
				backgroundColor = .tintColor.withAlphaComponent(.oneEighth)
				
				isUserInteractionEnabled_setTrueWithAxTrait()
				accessibilityCustomActions = []
			case .modalDisabled:
				backgroundColor_set_to_clear()
				
				isUserInteractionEnabled_setFalseWithAxTrait()
				accessibilityCustomActions = []
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		guard !Self.usesSwiftUI__ else { return }
		
		separatorInset.left = 0
		+ contentView.frame.minX
		+ titleLabel.frame.minX
		separatorInset.right = directionalLayoutMargins.trailing
	}
}
extension FolderCell: AvatarDisplaying__ {
	func indicateAvatarStatus__(
		_ avatarStatus: AvatarStatus
	) {
		guard !Self.usesSwiftUI__ else { return }
		
		spacerSpeakerImageView.maximumContentSizeCategory = .extraExtraExtraLarge
		speakerImageView.maximumContentSizeCategory = spacerSpeakerImageView.maximumContentSizeCategory
		
		spacerSpeakerImageView.image = UIImage(systemName: Avatar.preference.playingSFSymbolName)
		
		speakerImageView.image = avatarStatus.uiImage
		
		accessibilityLabel = [
			avatarStatus.axLabel,
			rowContentAccessibilityLabel__,
		].compactedAndFormattedAsNarrowList()
	}
}
