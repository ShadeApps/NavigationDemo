//
//  Constants.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

/// Constants of your App
public struct Constants {

	/// User defaults key values
	public struct UserDefaults {
		public struct General {
			/// Contains the last app version the app was launched at (e.g. 1.0.0).
			/// - Type: `String`
			/// - Default Value: `NONE`
			public static let lastAppVersionAppWasOpenedAt = "lastAppVersionAppWasOpenedAt"

			/// Contains a boolean value whether we have already asked the user to review our app via a system prompt.
			/// - Type: `Bool`
			/// - Default Value: `false`
			public static let alreadyAskedForAppReviewThroughSystemPrompt =
				"alreadyAskedForAppReviewThroughSystemPrompt"

			/// Should be incremented by one every time the user perfroms a "positive reinforcement action"
			///
			/// After the positiveActionPerformedTimes reaches the positive actions threshold (Constants.General.positiveActionThreshold)
			/// a prompt to review the app will be shown. (See RequestType.swift). An example for this would be if a user completes their 10th To-Do Task.
			///
			/// - Type: `Int`
			/// - Default Value: `0`
			public static let positiveActionPerformedCount = "positiveActionPerformedTimes"
		}
	}

	public struct General {
		/// Indicates how many positive actions should the user experience before an
		/// in-app review prompt is shown to the user
		public static let positiveActionThreshold: Int = 10
	}

	/// Constants regarding In-App-Notifications
	public struct InAppNotifications {
		/// How many notifications can be shown at once (if max is reached, the oldest notification will be removed)
		/// Note: duplicate notifications will not show up stacked
		public static let maxShownAtOnce: Int = 3

		/// The duration that the in-app notification appears on screen (in seconds)
		public static let showingDuration: Int = 6
	}

	/// Notification Names & UserInfo Keys for NotificationCenter (!= push notifications)
	public struct Notifications {

		/// See `askUserFor.swift`
		public struct UserActionRequest {
			/// Used to typesafely send a notification to notification center that will ask user
			/// for things like Camera Permission, Location, Microphone, etc. or ask the user to review the app.
			public static let shouldPerformRequest = Notification.Name("shouldPerformRequest")

			/// Dictionary Parameter Key for Notification Center (to pass data safely to a notification center notification)
			/// - Type: `RequestType`
			public static let requestTypeKey = "requestType"

			/// Dictionary Parameter Key for Notification Center (to pass data safely to a notification center notification)
			/// - Type: `RequestActions`
			public static let requestActionsKey = "requestActions"
		}

		/// See `showInAppnotification.swift`
		public struct InAppNotifications {
			/// Dictionary Parameter Key for Notification Center (to pass data safely to a notification center notification)
			/// - Type: `InAppNotificationData`
			public static let notificationDataKey = "notificationData"

			/// Used to typesafely send a notification to notification center that will show an in-app notification
			static let shouldShowInAppNotification = Notification.Name("shouldShowInAppNotification")
		}

	}

	/// App constants defined by you / app itself
	public struct AppData {
		/// Official app version (e.g. 1.0.0)
		public static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

		/// Your app's display name
		public static let appName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String

		/// Custom description of your app.
		/// Will be shown under the SignInView if AuthKit was selected during project generation
		public static let appDescription: LocalizedStringKey =
			"Description of \(appName).\nIt's truly an engineering marvel."

		/// User's preffered email client will open with this in sender field after tapping "Report a Problem" in SettingsView
		public static let supportEmail = "support@email.com"

		/// URL that links to developers website or social media (Will be shown in SettingsView under "About the Developer")
		public static let developerWebsite = "https://twitter.com/apple"

		/// Will be shown in the footer of the SettingsView with a copyright symbol and year
		public static let developerName = "App Developer LLC"

		/// URL to your app's ToS, will be shown in Settings/Privacy
		/// Should match the ToS in App Store Connect and in RevenueCat
		public static let termsOfServiceURL = "https://www.example.com/tos"

		/// URL to your app's Privacy Policy, will be shown in Settings/Privacy
		/// Should match the Privacy Policy in App Store Connect and in RevenueCat
		public static let privacyPolicyURL = "https://www.example.com/privacy-policy"
	}
}
