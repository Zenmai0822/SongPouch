//
//  Views - AlbumsTVC.swift
//  LavaRock
//
//  Created by h on 2020-07-10.
//

import UIKit

final class AlbumCell:
	UITableViewCell,
	NowPlayingIndicator
{
	@IBOutlet var artworkImageView: UIImageView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var releaseDateLabel: UILabel!
	@IBOutlet var nowPlayingIndicatorImageView: UIImageView!
}

final class AlbumCellWithoutReleaseDate:
	UITableViewCell,
	NowPlayingIndicator
{
	@IBOutlet var artworkImageView: UIImageView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var nowPlayingIndicatorImageView: UIImageView!
}
