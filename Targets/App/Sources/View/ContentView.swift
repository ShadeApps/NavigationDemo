//
//  ContentView.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

struct ContentView: View {

	var body: some View {
		TabView {

			// Pre-made Settings View for easy native-looking settings screen.
			Tab("Settings", systemImage: "gear") {
				SettingsView()
			}

			#if DEBUG

				TabSection("DEBUG ONLY") {
					// Use this to create quick settings and toggles to streamline the development process
					Tab("Developer", systemImage: "hammer") {
						DeveloperSettingsView()
					}
				}

			#endif
		}

		.tabViewStyle(.sidebarAdaptable)
		.tabViewSidebarHeader {
			Text("SwiftyLaunch App")
				.font(.title)
				.bold()
				.frame(maxWidth: .infinity, alignment: .leading)

		}

	}
}

#Preview {
	ContentView()
}
