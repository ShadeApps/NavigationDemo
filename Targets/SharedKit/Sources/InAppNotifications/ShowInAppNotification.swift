//
//  ShowInAppNotification.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

/// Call this function to show an in-app notification with a predefined style
/// Recommended: Use @MainActor when calling this function to avoid calling it from a background thread
public func showInAppNotification(
	_ type: InAppNotificationType,
	content: InAppNotificationContent,
	size: InAppNotificationStyle.NotificationSize? = nil,
	onTapAction: (() -> Void)? = nil
) {

	var style = type.style

	/// If a size is provided, create a new instance with the same properties as predifenied type style but with the new size
	if let size = size {
		style = InAppNotificationStyle(
			sfSymbol: style.sfSymbol,
			symbolColor: style.symbolColor,
			size: size

		)
	}

	let notificationData = InAppNotificationData(
		id: UUID(),
		content: content,
		style: style,
		onTap: onTapAction
	)

	NotificationCenter.default.post(
		name: Constants.Notifications.InAppNotifications.shouldShowInAppNotification,
		object: nil,
		userInfo: [
			Constants.Notifications.InAppNotifications.notificationDataKey: notificationData
		]
	)
}

/// Call this function to show an in-app notification with a custom style
/// Recommended: Use @MainActor when calling this function to avoid calling it from a background thread
public func showInAppNotification(
	content: InAppNotificationContent,
	style: InAppNotificationStyle,
	onTapAction: (() -> Void)? = nil
) {

	let notificationData = InAppNotificationData(
		id: UUID(),
		content: content,
		style: style,
		onTap: onTapAction
	)

	NotificationCenter.default.post(
		name: Constants.Notifications.InAppNotifications.shouldShowInAppNotification,
		object: nil,
		userInfo: [
			Constants.Notifications.InAppNotifications.notificationDataKey: notificationData
		]
	)
}

/// Will show a sheet that will ask the user to give permission for push notifications, when `showNotificationsPermissionsSheet()` is called
public struct ShowInAppNotificationsWhenCalledModifier: ViewModifier {

	@State private var shownNotifications: [InAppNotificationData] = []

	public init() {}

	//Find Notif with ID and remove it from the shown Notifications Array
	func dismissNotifWithID(_ id: UUID) {
		withAnimation(.interpolatingSpring()) {
			if let index = shownNotifications.firstIndex(where: { $0.id == id }) {
				shownNotifications.remove(at: index)
			}
		}
	}

	public func body(content: Content) -> some View {

		content
			.overlay {
				VStack {
					ForEach(shownNotifications, id: \.id) { notifData in
						InAppNotificationView(
							data: notifData,
							onDismiss: {
								dismissNotifWithID(notifData.id)
							}
						)
						.padding(.horizontal)
						.transition(
							notifData.style.size == .normal
								? .scale(scale: 0.3, anchor: .top).combined(with: .opacity)
								: .asymmetric(
									insertion: .move(edge: .top).combined(with: .opacity)
										.combined(with: .scale(scale: 0.6, anchor: .top)),
									removal: .scale(scale: 0.3, anchor: .top).combined(
										with: .opacity)))
					}
					Spacer()
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}

			.onReceive(
				NotificationCenter.default.publisher(
					for: Constants.Notifications.InAppNotifications.shouldShowInAppNotification
				)
			) { pub in
				let notificationData =
					pub.userInfo![Constants.Notifications.InAppNotifications.notificationDataKey]
					as! InAppNotificationData

				//Generate haptic feedback when notification appears
				Haptics.notification(type: notificationData.style.hapticsOnAppear)

				//check if there is already a max amount of notifications shown
				if shownNotifications.count >= Constants.InAppNotifications.maxShownAtOnce {
					//remove the last one
					_ = withAnimation(.interpolatingSpring()) {
						shownNotifications.removeLast()  // last one = oldest
					}
				}

				//append it to shownNotifications
				withAnimation(.interpolatingSpring()) {
					//to prevent the same notification from appearing multiple times, we just check if the style and content are the same
					if !(shownNotifications.count > 0
						&& shownNotifications[0].content == notificationData.content
						&& shownNotifications[0].style == notificationData.style)
					{
						shownNotifications.insert(notificationData, at: 0)
					}
				}

				//start a time to remove it from shownNotifications
				Task {
					try? await Task.sleep(for: .seconds(Constants.InAppNotifications.showingDuration))
					dismissNotifWithID(notificationData.id)
				}
			}
	}
}

#Preview {
	Button("Kablamo!") {

		let random = Int.random(in: 1...8)

		if random == 1 {
			showInAppNotification(
				.error, content: InAppNotificationContent(title: "Error", message: "Error Message"),
				onTapAction: {
					print("Tappy Tap Error!")
				})
		} else if random == 2 {
			showInAppNotification(
				.info, content: InAppNotificationContent(title: "Info", message: "Info Message"),
				onTapAction: {
					print("Tappy Tap Info!")
				})
		} else if random == 3 {
			showInAppNotification(
				.warning, content: InAppNotificationContent(title: "Warning", message: "Warning Message"),
				onTapAction: {
					print("Tappy Tap Warning!")
				})
		} else if random == 4 {
			showInAppNotification(
				.success, content: InAppNotificationContent(title: "Success", message: "Success Message"),
				size: .compact,
				onTapAction: {
					print("Tappy Tap Success!")
				})
		} else if random == 5 {
			showInAppNotification(
				.failure, content: InAppNotificationContent(title: "Failure", message: "Failure Message"),
				onTapAction: {
					print("Tappy Tap Failure!")
				})
		} else if random == 6 {
			showInAppNotification(
				content: InAppNotificationContent(
					title: "Custom Notification", message: "Custom Notification Message"),
				style: InAppNotificationStyle(
					sfSymbol: "pencil.tip.crop.circle", symbolColor: .indigo, size: .normal))
		} else if random == 7 {
			showInAppNotification(
				content: InAppNotificationContent(
					title: "Custom Notification", message: "Custom Notification Message"),
				style: InAppNotificationStyle(
					sfSymbol: "pencil.tip.crop.circle", symbolColor: .indigo, size: .compact))
		} else {
			showInAppNotification(
				content: InAppNotificationContent(title: "Custom Notification", message: "Mini Message"),
				style: InAppNotificationStyle(
					sfSymbol: "pencil.tip.crop.circle", symbolColor: .indigo, size: .compact))
		}
	}
	.frame(maxWidth: .infinity, maxHeight: .infinity)
	.modifier(ShowInAppNotificationsWhenCalledModifier())
}
