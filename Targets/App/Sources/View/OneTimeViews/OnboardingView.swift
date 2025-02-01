//
//  OnboardingView.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SharedKit
import SwiftUI

/// Set this to the views you want to show during Onboarding (first App launch ever)
/// Use these 3-4 views max to showcase the main selling point of your Application
/// Add the count in forEach loop below when adding or removing views here (swift doesnt like if its dynamic onboardingPages.count)
private let onboardingPages: [AnyView] = [
	AnyView(
		HeroView(
			sfSymbolName: "scribble.variable",
			title: "Onboarding Page 1",
			subtitle: "Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit, sed do.",
			bounceOnAppear: true
		)),
	AnyView(
		HeroView(
			sfSymbolName: "timeline.selection", title: "Onboarding Page 2",
			subtitle: "Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit, sed do.")),
	AnyView(
		HeroView(
			sfSymbolName: "person.3.fill", title: "Onboarding Page 3",
			subtitle: "Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit, sed do.")),
]

/// Is attached to the root ContentView in App.swift, and shown when the app version saved in UserDefaults
/// is NONE (means the user opens the app for the first time ever, as we save the current app version when the app is opened)
struct ShowOnboardingViewOnFirstLaunchEverModifier: ViewModifier {

	@AppStorage(Constants.UserDefaults.General.lastAppVersionAppWasOpenedAt)
	private var lastAppVersionAppWasOpenedAt: String = "NONE"

	@State private var showOnboarding: Bool = false

	func body(content: Content) -> some View {
		Group {
			if showOnboarding {
				OnboardingView {
					withAnimation(.bouncy) {
						showOnboarding = false
					}
				}
				.transition(.opacity)
			} else {
				content
					.transition(.opacity)
			}
		}
		// Do not move this into init(), as it may be called multiple times, which will result in the OnboardingView never being shown!
		.onAppear {
			// Convenience to see the OnboardingView in the preview every time
			// Otherwise, only show onboarding on the first app launch ever
			if isPreview {
				self.showOnboarding = true
			} else {
				self.showOnboarding = lastAppVersionAppWasOpenedAt == "NONE"
			}
		}
	}

	/// Carousel with multiple views from the `onboardingPages` array.
	/// Users can move forward and backward via swipe gestures or by pressing the "Continue" button.
	/// On the last page the button says "Finish Onboarding" and will close the onboarding view.
	struct OnboardingView: View {
		@State var pageIndex: Int = 0

		/// Is called when the user is on last page -> finish Onboarding
		let onCompletion: () -> Void

		var body: some View {
			VStack {
				TabView(selection: $pageIndex) {
					ForEach(0..<3) { index in  // <- Add the count here when adding or removing views in onboardingPages above
						onboardingPages[index]
							.tag(index)
					}
				}
				.tabViewStyle(.page(indexDisplayMode: .never))  // don't show the page dots

				Button(pageIndex == onboardingPages.count - 1 ? "Finish Onboarding" : "Next") {
					withAnimation {
						if pageIndex == onboardingPages.count - 1 {
							onCompletion()
						} else {
							pageIndex += 1
						}
					}
				}
				.buttonStyle(.cta())
				.padding(.horizontal)
				.padding(.bottom)
			}
			.accentBackground(strong: true)
		}
	}
}

#Preview {
	Text("Hello")
		.modifier(ShowOnboardingViewOnFirstLaunchEverModifier())
}
