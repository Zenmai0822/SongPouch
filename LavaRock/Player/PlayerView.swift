//
//  PlayerView.swift
//  LavaRock
//
//  Created by h on 2022-01-31.
//

import SwiftUI

final class PlayerHostingController: UIHostingController<PlayerView> {
	required init?(coder: NSCoder) {
		super.init(coder: coder, rootView: PlayerView())
	}
}

struct PlayerView: View {
    var body: some View {
		NavigationView {
			VStack {
				List {
					Text("song title")
					Text("song title")
					Text("song title")
					Text("song title")
					Text("song title")
					Text("song title")
				}
				TransportPanel()
					.padding()
			}
			.navigationTitle("Queue")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button("Shuffle") {
						
					}
				}
			}
		}
    }
}
