//
//  RequireCapabilityPermission.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

struct RequireCapabilityPermissionViewModifier: ViewModifier {

    @Environment(\.dismiss) private var dismiss
	@Environment(\.scenePhase) var scenePhase
	let permissionRequirement: RequestType
	let onSuccess: () -> Void  //means we got the permission
	let onCancel: () -> Void  //means we didn't get the permission
	@State var gotAccess = false
	@State private var showRequestSheet = false

	init(permissionRequirement: RequestType, onSuccess: @escaping () -> Void, onCancel: @escaping () -> Void) {
		self.permissionRequirement = permissionRequirement
		self.onSuccess = onSuccess
		self.onCancel = onCancel
	}

	func body(content: Content) -> some View {
		content
			.overlay {
				if !gotAccess {
					// Trigger the modal sheet presentation
					Color.clear
						.sheet(isPresented: $showRequestSheet, onDismiss: {
							// If dismissed without granting, notify onCancel
							onCancel()
						}) {
							RequestCapabilityContentView(
								type: permissionRequirement,
								onSuccessfulAccept: {
									gotAccess = true
									showRequestSheet = false
									onSuccess()
								},
								onDismiss: {
									showRequestSheet = false
									onCancel()
								}
							)
							.navigationBarTitleDisplayMode(.inline)
						}
						.onAppear {
							showRequestSheet = true
						}
				}
			}
			.onAppearAndChange(of: scenePhase) {
				if permissionRequirement == .appRating { return }
				Task {
					let permissionStatus = await permissionRequirement.permissionStatus()
					gotAccess = permissionStatus == .gotPermission
				}
			}
			.task {
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
