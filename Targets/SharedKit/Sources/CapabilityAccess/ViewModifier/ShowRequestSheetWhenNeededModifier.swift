//
//  ShowRequestSheetWhenNeededModifier.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

public struct ShowRequestSheetWhenNeededModifier: ViewModifier {

	@State private var currentRequestType: RequestType?
	@State private var currentRequestActions: RequestActions?

	public init() {}

	public func body(content: Content) -> some View {

		content
			.sheet(
				item: $currentRequestType,
				onDismiss: {
					// if we passed a closure to execute when the user dismisses the permission, we will execute it here
					if let onDismiss = currentRequestActions?.onDismiss {
						onDismiss()
					}
					currentRequestType = nil
					currentRequestActions = nil
				},
				content: { type in
					RequestCapabilityContentView(
						type: type,
						onSuccessfulAccept: {
							// if we passed a closure to execute when the user accepts the permission, we will execute it here
							if let executeIfGotAccess = currentRequestActions?.executeIfGotAccess {
								executeIfGotAccess()
							}
							currentRequestType = nil
							currentRequestActions = nil
						},
						onDismiss: {
							// if we passed a closure to execute when the user dismisses the permission, we will execute it here
							if let onDismiss = currentRequestActions?.onDismiss {
								onDismiss()
							}
							currentRequestType = nil
							currentRequestActions = nil
						}
					)
				}
			)

			.onReceive(
				NotificationCenter.default.publisher(
					for: Constants.Notifications.UserActionRequest.shouldPerformRequest
				)
			) { pub in
				Task {
					let requestType =
						pub.userInfo![Constants.Notifications.UserActionRequest.requestTypeKey]
						as! RequestType
					let requesestActions =
						pub.userInfo![Constants.Notifications.UserActionRequest.requestActionsKey]
						as! RequestActions

					let permissionStatus = await requestType.permissionStatus()

					// Means that we don't have to show the sheet, so we just return
					// and execute the closure that is passed when we have permission
					if permissionStatus == .gotPermission {
						if let executeIfGotAccess = requesestActions.executeIfGotAccess {
							executeIfGotAccess()
						}
						return
					}

					currentRequestType = requestType
					currentRequestActions = requesestActions
				}
			}
	}
}

/// Is shown by the `ShowRequestSheetWhenNeededModifier` when the user needs to be asked for something. (see `askUserFor.swift` in SharedKit)
struct RequestCapabilityContentView: View {

	@Environment(\.scenePhase) var scenePhase

	private let type: RequestType

	/// The text of the CTA button (Value depends on if we already asked before)
	@State private var ctaText: LocalizedStringKey  //

	/// Will be executed when user presses on the ACCEPT CTA button (Value depends on if we already prompted the user before)
	/// Returns bool indicating we got access or not, if we got access, will execute `onSuccessfulAccept()`
	@State private var onAccept: (() async -> Bool)

	/// Will be executed when the user presses the accept cta button and it successfully goes through.
	private let onSuccessfulAccept: (() -> Void)

	/// Will be executed when the user presses on the dismiss button
	private let onDismiss: (() -> Void)

	init(
		type: RequestType,
		onSuccessfulAccept: @escaping (() -> Void),
		onDismiss: @escaping (() -> Void)
	) {
		self.type = type
		self.ctaText = type.data.ctaText
		self.onAccept = type.requestAction
		self.onSuccessfulAccept = onSuccessfulAccept
		self.onDismiss = onDismiss
	}

	var body: some View {
		VStack {

			Spacer()

			HeroView(
				sfSymbolName: type.data.sfSymbolName,
				title: type.data.title,
				subtitle: type.data.subtitle,
				bounceOnAppear: true
			)

			Spacer()

			if let footerNote = type.data.footerNote {
				Text(footerNote)
					.foregroundStyle(.secondary)
					.font(.caption)
					.lineLimit(1)
					.minimumScaleFactor(0.1)
			}

			Button(ctaText) {
				Task {
					if await onAccept() {
						onSuccessfulAccept()
					} else {
						onDismiss()
					}
				}
			}
			.buttonStyle(.cta())

			// we want to show "Later" for the review request
			Button(type == .appRating ? "Later" : "Dismiss") {
				onDismiss()
			}
			.buttonStyle(.secondary())

		}
		.padding()
		.accentBackground(strong: true)
		.onAppearAndChange(of: scenePhase) {  // Maybe the user has changed the permission settings in the settings app and came back

			// We don't need to check that for the app rating
			// Especially because calling.permissionStatus() will affect the permissionStatus result (see its implementation)
			// So calling it twice in a row (which will happen, because we check that in .onReceive() above for the first time) might lead to unexpected behaviour (like it opening and closing instantly)
			if type == .appRating { return }

			Task {
				let permissionStatus = await type.permissionStatus()

				// if we got permission, simply dismiss the sheet
				if permissionStatus == .gotPermission {
					onSuccessfulAccept()
					return
				}

				// If we got denied permission, prompt the user to give it in settings
				if permissionStatus == .denied {
					ctaText = "Allow in Settings"
					onAccept = openAppInSettings

					// you can also dismiss directly if the user denied the permission
					// onDismiss()
					return
				}
			}
		}
	}
}

#Preview {
	Button("Kablamo!") {
		askUserFor(.locationAccess)
	}
	.frame(maxWidth: .infinity, maxHeight: .infinity)
	.modifier(ShowRequestSheetWhenNeededModifier())
}
