//
//  AskUserFor.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

/// Actions that you might want to do depending if we get users permission / action performs successfully or the user dismisses it
struct RequestActions {
	let executeIfGotAccess: (() -> Void)?
	let onDismiss: (() -> Void)?  //what to do if the user presses on dismiss button
}

/// Call this function to ask the user for something (Permission Requests, Ratings, etc.)
/// Recommended: Use @MainActor when calling this function to avoid calling it from a background thread
public func askUserFor(_ type: RequestType, executeIfGotAccess: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil) {
	NotificationCenter.default.post(
		name: Constants.Notifications.UserActionRequest.shouldPerformRequest,
		object: nil,
		userInfo: [
			Constants.Notifications.UserActionRequest.requestTypeKey: type,
			Constants.Notifications.UserActionRequest.requestActionsKey: RequestActions(
				executeIfGotAccess: executeIfGotAccess,
				onDismiss: onDismiss
			),
		]
	)
}
