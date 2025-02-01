//
//  PrivacyView.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SharedKit
import SwiftUI

struct PrivacyView: View {

	@State private var showPrivacyPolicy = false
	@State private var showToS = false

	var body: some View {
		VStack {
			List {
				Section {
					Button("Privacy Policy") {
						showPrivacyPolicy = true
					}

					Button("Terms of Service") {
						showToS = true
					}
				}

			}
		}
		.navigationTitle("Privacy")
	}
}

#Preview {
	NavigationStack {
		PrivacyView()
	}
}
