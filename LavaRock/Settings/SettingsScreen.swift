//
//  SettingsScreen.swift
//  LavaRock
//
//  Created by h on 2022-01-15.
//

import SwiftUI

struct SettingsScreen__SwiftUI: View {
	@Environment(\.dismiss) private var dismiss
	
	@ObservedObject private var theme: Theme = .shared
	@ObservedObject private var tipJarViewModel: TipJarViewModel = .shared
	
	var body: some View {
		NavigationView {
			Form {
				Section(LRString.appearance) {
					LightingPicker()
					
					AccentColorPicker()
					
					AvatarPicker()
				}
				
				Section {
					TipJarView()
				} header: {
					Text(LRString.tipJar)
				} footer: {
					Text(LRString.supportFooter)
				}
			}
			.navigationTitle(LRString.settings)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button(LRString.done) {
						dismiss()
					}
				}
			}
		}
		.navigationViewStyle(.stack)
		.tint(theme.accentColor.color) // Without this, SwiftUI applies “Increase Contrast” twice.
	}
}
