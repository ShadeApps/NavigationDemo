//
//  SettingsView.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SharedKit
import SwiftUI

struct SettingsView: View {

	/// Settings NavigationStack. Be careful not to wrap NavigationStack inside another NavigationStack. This may lead to weird bugs.
	@State private var settingsPath = NavigationPath()

	/// We pass this function to closures that may need a dismiss action, to return back to the root settings view
	/// For example, user has an account -> goes to account settings -> deletes an account, so we forward him back to root
	func popToRoot() {
		settingsPath = NavigationPath()
	}

	var body: some View {
		NavigationStack(path: $settingsPath) {
			List {

				// General Settings Sections
				Section {
					let generalSettings: [SettingsPath] = [
						.general,
						.appearance,
						/// Requires Premium to access (otherwise will show the premium sheet on tap)
						.privacy,
					]
					ForEach(generalSettings, id: \.data.iconName) { setting in
						SettingsRowItem(setting)
					}
				}

				// Developer Contact Section
				Section {
					LinkRow(
						url: URL(string: "\(Constants.AppData.developerWebsite)")!,
						setting: .aboutDeveloper)
					LinkRow(
						url: URL(string: "mailto:\(Constants.AppData.supportEmail)")!, setting: .reportBug
					)
				} footer: {
					Text("© \(Date.now, format: .dateTime.year()), \(Constants.AppData.developerName)")
				}

			}
			.navigationTitle("Settings")
			.navigationDestination(for: SettingsPath.self) { setting in

				switch setting {
					case .appearance:
						// Note: Requires Premium (When InAppPurchaseKit is enabled)
						AppearanceView(popBackToRoot: popToRoot)
					case .privacy:
						PrivacyView()
					default:
						// If an undefined destination -> Show a Text with the setting label
						ZStack {
							Text(setting.data.label)
						}
						.navigationTitle(setting.data.label)
				}
			}
		}
	}
}

struct SettingsRowItem: View {

	let setting: SettingsPath

	init(_ setting: SettingsPath) {
		self.setting = setting
	}

	var body: some View {
		NavigationLink(value: setting) {
			HStack(spacing: 15) {
				Image(systemName: setting.data.iconName)
					.foregroundStyle(setting.data.iconForegroundColor)
					.font(.callout)
					.frame(width: 25, height: 25)
					.background(setting.data.iconBackgroundColor.gradient)
					.clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
				Text(setting.data.label)
			}
		}
	}
}

/// Same as SettingsRowItem but with a URL Link
struct LinkRow: View {

	let url: URL
	let setting: SettingsPath

	var body: some View {
		Link(
			destination: url,
			label: {
				SettingsRowItem(setting)
			}
		)
		.buttonStyle(.borderless)
		.foregroundStyle(.primary)

	}
}

enum SettingsPath: Hashable, Equatable {
	case general
	case appearance
	case privacy
	case aboutDeveloper
	case reportBug

	var data: SettingsRowData {
		switch self {
			case .general:
				SettingsRowData(iconName: "gear", label: "General", analyticsDescription: "general")
			case .appearance:
				SettingsRowData(
					iconName: "paintbrush.fill", iconBackgroundColor: .purple, label: "Appearance",
					analyticsDescription: "appearance")
			case .privacy:
				SettingsRowData(
					iconName: "hand.raised.fill", iconBackgroundColor: .blue, label: "Privacy",
					analyticsDescription: "privacy")
			case .aboutDeveloper:
				SettingsRowData(
					iconName: "hammer.fill", iconBackgroundColor: .blue, label: "About the Developer",
					analyticsDescription: "about_developer")
			case .reportBug:
				SettingsRowData(
					iconName: "exclamationmark.bubble.fill", iconBackgroundColor: .orange,
					label: "Report a Problem", analyticsDescription: "report_problem")
		}
	}
}

public struct SettingsRowData: Hashable {
	let id = UUID()
	var iconName: String = "gear"
	var iconForegroundColor: Color = Color.white
	var iconBackgroundColor: Color = Color.gray
	var label: LocalizedStringKey
	var analyticsDescription: String

	// to conform to hashable
	public func hash(into myhasher: inout Hasher) {
		myhasher.combine(id)
	}
}

#Preview {
	SettingsView()
}
