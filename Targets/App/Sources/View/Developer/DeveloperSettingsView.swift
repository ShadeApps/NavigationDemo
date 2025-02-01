//
//  DeveloperSettingsView.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SharedKit
import SwiftUI

struct DeveloperSettingsView: View {

	/// Will persist the setting on whether to always require biometric auth or just hide the view in the app switcher.
	///
	/// Used as a demo for .sensitiveView()
	@AppStorage("protectDeveloperViewWithBiometrics") private var protectDeveloperViewWithBiometrics: Bool = false

	@State var showOnboarding = false
	@State var showFeatureSheet = false

	var body: some View {
		NavigationStack {
			#if DEBUG
				List {
					Section {
						Button("Show Onboarding") {
							showOnboarding = true
						}

						Button("Show Feature Sheet") {
							showFeatureSheet = true
						}

						Button("Reset UserDefaults") {
							UserDefaults.standard.clear()
						}

						Button("Send InApp Notification") {
							showInAppNotification(
								.info,
								content: InAppNotificationContent(
									title: "Info Notification",
									message: "This is a normal Notification"),
								size: .normal
							) {
								print("hello")
							}
						}

						Button("Send Compact InApp Notification") {
							showInAppNotification(
								content: .init(
									title: "Custom Notification",
									message: "Compact Notification"),
								style: .init(
									sfSymbol: "star.fill", symbolColor: .indigo,
									size: .compact)
							)
						}

						Toggle(
							"Protect this View with Biometrics",
							isOn: $protectDeveloperViewWithBiometrics)
					}

					Section(header: Text("Ask User For...")) {

						// just examples on how to use `askUserFor` actions.
						Button("Will Ask for Review on 10th tap") {
							askUserFor(.appRating) {
								print(
									"Won't show rating sheet. Already prompted or not performing for the 10th time."
								)
							} onDismiss: {
								print("User Dimissing Rating Sheet.")
							}
						}

						Button("Ask for Photo Library Permission") {
							askUserFor(.photosAccess) {
								showInAppNotification(
									.success,
									content: .init(
										title: "Got Photos Access!", message: "Nice."))
							} onDismiss: {
								showInAppNotification(
									.warning,
									content: .init(
										title: "Dismissed :(",
										message: "User Declined Permission."))
							}
						}

						Button("Ask for Camera Permission") {
							askUserFor(.cameraAccess)
						}

						Button("Ask for Microphone Permission") {
							askUserFor(.microphoneAccess)
						}

						Button("Ask for Location Access") {
							askUserFor(.locationAccess)
						}

						Button("Ask for Contacts Access") {
							askUserFor(.contactsAccess)
						}

						Button("Ask for Calendar Access") {
							askUserFor(.calendarAccess)
						}

						Button("Ask for Reminders Access") {
							askUserFor(.remindersAccess)
						}
					}

				}
				.navigationTitle("Developer Settings")
				.sheet(isPresented: $showFeatureSheet) {
					ShowFeatureSheetOnNewAppVersionModifier.WhatsNewView {
						showFeatureSheet = false
					}
				}
				.sheet(isPresented: $showOnboarding) {
					ShowOnboardingViewOnFirstLaunchEverModifier.OnboardingView {
						showOnboarding = false
					}
				}

			#endif
		}
		.sensitiveView(protectWithBiometrics: protectDeveloperViewWithBiometrics)
	}
}

#Preview {
	DeveloperSettingsView()
}
