//
//  SongsView.swift
//  LavaRock
//
//  Created by h on 2020-06-26.
//  Copyright © 2020 h. All rights reserved.
//

import SwiftUI

struct SongsView: View {
	
	let pathToSampleArtwork = Bundle.main.path(forResource: "fallinLight", ofType: "jpg")!
//	let albumTitle: String
	
	init() {
		// Removes the blank cells below the List.
		UITableView.appearance().tableFooterView = UIView()
	}
	
	var body: some View {
		VStack {
			Image(uiImage: UIImage(contentsOfFile: pathToSampleArtwork)!)
				.resizable()
				.padding(.all, 0)
				.scaledToFit()
			List(/*@START_MENU_TOKEN@*/0 ..< 5/*@END_MENU_TOKEN@*/) { item in
				Text("Song")
			}
			.padding(.all, 0)
//			.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
		}
//	.navigationBarItems(trailing: EditButton()) // As of iOS 13.5.1, doesn't appear until the show segue animation finishes, and removes the title in the navigation bar.
	}
}

struct SongsView_Previews: PreviewProvider {
    static var previews: some View {
		SongsView()
    }
}
