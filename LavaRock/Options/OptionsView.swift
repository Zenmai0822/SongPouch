//
//  OptionsView.swift
//  LavaRock
//
//  Created by h on 2022-01-15.
//

import SwiftUI

struct OptionsView: View {
	@Environment(\.dismiss) var dismiss
	
    var body: some View {
		NavigationView {
			List {
				Text("Options View")
			}
			.navigationTitle(LocalizedString.options)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				Button { dismiss() } label: { Text(LocalizedString.done).bold() }
			}
		}
		.navigationViewStyle(.stack)
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView()
    }
}
