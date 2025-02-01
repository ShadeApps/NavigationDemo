//
//  RequireCapabilityPermission.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

struct RequireCapabilityPermissionViewModifier: ViewModifier {

	@Environment(\.scenePhase) var scenePhase
	let permissionRequirement: RequestType
	let onSuccess: () -> Void  //means we got the permission
	let onCancel: () -> Void  //means we didn't get the permission
	@State var gotAccess = false

	init(permissionRequirement: RequestType, onSuccess: @escaping () -> Void, onCancel: @escaping () -> Void) {
		self.permissionRequirement = permissionRequirement
		self.onSuccess = onSuccess
		self.onCancel = onCancel
	}

	func body(content: Content) -> some View {
		///Show the content, otherwise show RequestSheetContentView
		if gotAccess {
			content
				.onAppearAndChange(of: scenePhase) {

					if permissionRequirement == .appRating { return }

					Task {
						let permissionStatus = await permissionRequirement.permissionStatus()

						/// if we got permission, just show the content
						if permissionStatus == .gotPermission {
							gotAccess = true
							return
						}

						/// If we got denied permission, prompt the user to give it in settings
						if permissionStatus == .denied {
							gotAccess = false
						}
					}
				}
				.transition(.opacity)

		} else {
			RequestCapabilityContentView(
				type: permissionRequirement,
				onSuccessfulAccept: {
					withAnimation {
						gotAccess = true
						onSuccess()
					}
				},
				onDismiss: {
					withAnimation {
						onCancel()
					}
				}
			)
			.transition(.opacity)
			// why the navigationBarTitleDisplayMode? Because we usually don't need this, but can lead to unwanted visual glitches when
			// displaying in a NavigationStack (swiftui at first shows this view and if we got permission,
			// will instantly switch to another)
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

extension View {
	/// This modifier makes sure that the view that it is applied to will only be shown if the user has granted us with the required permissions
	public func requireCapabilityPermission(
		of permissionRequirement: RequestType,
		onSuccess: @escaping () -> Void = {},
		onCancel: @escaping () -> Void = {}
	)
		-> some View
	{
		modifier(
			RequireCapabilityPermissionViewModifier(
				permissionRequirement: permissionRequirement, onSuccess: onSuccess, onCancel: onCancel))
	}
}
