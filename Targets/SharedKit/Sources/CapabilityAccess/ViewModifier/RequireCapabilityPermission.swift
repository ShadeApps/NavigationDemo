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
		Group {
			if gotAccess {
				content
					.onAppearAndChange(of: scenePhase) {
						if permissionRequirement == .appRating { return }

						Task {
							let permissionStatus = await permissionRequirement.permissionStatus()
							
							/// Update access state without animation
							gotAccess = permissionStatus == .gotPermission
						}
					}
			} else {
				RequestCapabilityContentView(
					type: permissionRequirement,
					onSuccessfulAccept: {
						gotAccess = true
						onSuccess()
					},
					onDismiss: onCancel
				)
				.navigationBarTitleDisplayMode(.inline)
			}
		}
		.task {
			// Check permission status immediately on view load
			if permissionRequirement != .appRating {
				let permissionStatus = await permissionRequirement.permissionStatus()
				if permissionStatus == .gotPermission {
					gotAccess = true
					onSuccess()
				}
			}
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
