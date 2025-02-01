//
//  SensitiveView.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

struct SensitiveViewModifier: ViewModifier {

	/// Current App State (not really app, but scene but ok). To check if the app is in the foreground
	@Environment(\.scenePhase) var scenePhase

	/// false: Simply hide the view screen when its in app switcher
	/// true: Will hide the view every time the view or the app becomes inactive. Will require a Biometric Authentication to be unlocked again
	private let protectWithBiometrics: Bool

	/// Self-explanatory.
	@State private var hideView: Bool

	/// called by .onAppear and .onDissapear
	@State private var viewIsActive: Bool

	public init(protectWithBiometrics: Bool) {
		// if we protect the view with biometrics, the view will be hidden by default (on appear)
		self.hideView = protectWithBiometrics
		self.protectWithBiometrics = protectWithBiometrics
		self.viewIsActive = false
	}

	/// Perform a Biometric Authentication, if it succeds, will set hideView to false
	func tryToUnlock() {
		Task {
			await BiometricAuth.executeIfSuccessfulAuth {
				withAnimation {
					hideView = false
				}
			}
		}
	}

	func body(content: Content) -> some View {
		content
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.overlay {
				if hideView {
					VStack {
						Image(systemName: "lock.fill")
							.foregroundStyle(Color.secondary)
							.font(.system(size: 75, weight: .semibold))
							.padding(.bottom, 10)

						Text("Private View")
							.font(.largeTitle)
							.bold()

						Text(
							"Open the App\(protectWithBiometrics ? " and authenticate " : " ")to see it."
						)
						.font(.callout)
						.multilineTextAlignment(.center)
						.foregroundStyle(.secondary)

						if protectWithBiometrics {
							Button("Unlock") {
								tryToUnlock()
							}
							.padding(.top)
						}

					}
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.background(.thickMaterial)
					.ignoresSafeArea()
				}
			}

			// if ScenePhase changes
			.task(id: scenePhase) {

				// and view is not active -> don't do anything
				if !viewIsActive { return }

				// but,
				withAnimation {
					// if the scenePhase changes into background -> hide the view
					if scenePhase != .active {
						hideView = true
						return
					}

					// otherwise, if the app comes to foreground and view hidden
					// unhide it. (but not if the view is protected by biometrics:
					// this requires a call to the `tryToUnlock()` function
					if hideView, !protectWithBiometrics {
						hideView = false
					}
				}
			}

			// if the view becomes active (example: the view becomes the currently active tab)
			.onAppear {
				viewIsActive = true

				// and the view is protected by biometrics: try to unlock
				if protectWithBiometrics {
					tryToUnlock()
				}
			}

			// if the view becomes inactive (example: user switches tabs)
			.onDisappear {
				viewIsActive = false

				// and the view is protected by biometrics: hide the view
				if protectWithBiometrics {
					hideView = true
				}
			}
	}
}

extension View {

	/// Protects a view with the requirement of having to biometrically authenticate in order to see the view (if protectWithBiometrics set to `true`)
	/// Additionally hides the view in the App Switcher
	public func sensitiveView(protectWithBiometrics: Bool = false) -> some View {
		modifier(SensitiveViewModifier(protectWithBiometrics: protectWithBiometrics))
	}
}
