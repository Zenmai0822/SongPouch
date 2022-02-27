//
//  Albums - Views.swift
//  LavaRock
//
//  Created by h on 2020-07-10.
//

import UIKit
import OSLog

final class MoveHereCell: TintedSelectedCell {
	@IBOutlet private var moveHereLabel: UILabel!
	
	final override func awakeFromNib() {
		super.awakeFromNib()
		
		accessibilityTraits.formUnion(.button)
		
		moveHereLabel.textColor = .tintColor
	}
}

final class AlbumCell:
	TintedSelectedCell,
	CellHavingTransparentBackground
{
	enum Mode {
		case normal
		case modal
		case modalTinted
	}
	
	@IBOutlet private var mainStack: UIStackView!
	@IBOutlet private var artworkImageView: UIImageView!
	@IBOutlet private var textStack: UIStackView!
	@IBOutlet private var titleLabel: UILabel!
	@IBOutlet private var releaseDateLabel: UILabel!
	@IBOutlet var nowPlayingImageView: UIImageView!
	
	final override func awakeFromNib() {
		super.awakeFromNib()
		
		setTransparentBackground()
		
		artworkImageView.accessibilityIgnoresInvertColors = true
		
		configureForTraitCollection()
	}
	
	final func configure(
		with album: Album,
		mode: Mode
	) {
		let title: String = album.titleFormattedOrPlaceholder() // Don’t let this be `nil`.
		
		os_signpost(.begin, log: .albumsView, name: "Draw and set artwork image")
		artworkImageView.image = {
			let maxWidthAndHeight = artworkImageView.bounds.width
			return album.artworkImage(
				at: CGSize(
					width: maxWidthAndHeight,
					height: maxWidthAndHeight))
		}()
		os_signpost(.end, log: .albumsView, name: "Draw and set artwork image")
		titleLabel.text = title
		releaseDateLabel.text = album.releaseDateEstimateFormatted()
		 
		if releaseDateLabel.text == nil {
			// We couldn’t determine the album’s release date.
			textStack.spacing = 0
		} else {
			textStack.spacing = 4
		}
		
		switch mode {
		case .normal:
			setTransparentBackground()
			accessoryType = .disclosureIndicator
			enableWithAccessibilityTrait()
		case .modal:
			setTransparentBackground()
			accessoryType = .none
			disableWithAccessibilityTrait()
		case .modalTinted:
			backgroundColor = .tintColor.translucentFaint()
			accessoryType = .none
			disableWithAccessibilityTrait()
		}
		
		accessibilityUserInputLabels = [title]
	}
	
	final override func traitCollectionDidChange(
		_ previousTraitCollection: UITraitCollection?
	) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		if
			previousTraitCollection?.preferredContentSizeCategory
				!= traitCollection.preferredContentSizeCategory
		{
			configureForTraitCollection()
		}
	}
	
	private func configureForTraitCollection() {
		if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
			mainStack.axis = .vertical
			mainStack.alignment = .leading
			mainStack.spacing = UIStackView.spacingUseSystem
		} else {
			mainStack.axis = .horizontal
			mainStack.alignment = .center
			mainStack.spacing = 12
		}
	}
}
extension AlbumCell: NowPlayingIndicating {}
