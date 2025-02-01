//
//  InAppNotificationView.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

/// Pre-Made Notification Styles
public enum InAppNotificationType {
	case error
	case warning
	case info
	case success
	case failure

	var style: InAppNotificationStyle {
		switch self {
			case .error:
				return InAppNotificationStyle(
					sfSymbol: "exclamationmark.triangle", symbolColor: Color.red, size: .compact,
					hapticsOnAppear: .error)
			case .warning:
				return InAppNotificationStyle(
					sfSymbol: "exclamationmark.triangle", symbolColor: Color.yellow, size: .compact,
					hapticsOnAppear: .warning)
			case .info:
				return InAppNotificationStyle(
					sfSymbol: "info.circle", symbolColor: Color.blue, size: .compact,
					hapticsOnAppear: .warning)
			case .success:
				return InAppNotificationStyle(
					sfSymbol: "checkmark.circle", symbolColor: Color.green, size: .compact,
					hapticsOnAppear: .success)
			case .failure:
				return InAppNotificationStyle(
					sfSymbol: "xmark.circle", symbolColor: Color.red, size: .compact, hapticsOnAppear: .error)
		}
	}
}

public struct InAppNotificationData {
	let id: UUID
	let content: InAppNotificationContent
	let style: InAppNotificationStyle
	let onTap: (() -> Void)?
	// perform an action if the user taps the notification
	// will also be shown when user 3D Touches the notification

	public init(
		id: UUID,
		content: InAppNotificationContent,
		style: InAppNotificationStyle,
		onTap: (() -> Void)?
	) {
		self.id = id
		self.content = content
		self.style = style
		self.onTap = onTap
	}
}

public struct InAppNotificationContent: Equatable {
	let title: LocalizedStringKey
	let message: LocalizedStringKey

	public init(title: LocalizedStringKey, message: LocalizedStringKey) {
		self.title = title
		self.message = message
	}
}

public struct InAppNotificationStyle: Equatable {

	public enum NotificationSize {
		case normal  // default
		case compact  // for quick info
	}

	let sfSymbol: String
	let symbolColor: Color
	let size: NotificationSize
	let hapticsOnAppear: UINotificationFeedbackGenerator.FeedbackType

	public init(
		sfSymbol: String,
		symbolColor: Color,
		size: NotificationSize,
		hapticsOnAppear: UINotificationFeedbackGenerator.FeedbackType = .warning
	) {
		self.sfSymbol = sfSymbol
		self.symbolColor = symbolColor
		self.size = size
		self.hapticsOnAppear = hapticsOnAppear
	}
}

public struct InAppNotificationView: View {

	let data: InAppNotificationData
	let onDismiss: () -> Void  // when user swipes up the notification or when dismiss is pressed in the context menu

	public var body: some View {

		if data.style.size == .normal {
			HStack(spacing: 10) {
				Image(systemName: data.style.sfSymbol)
					.font(.title)
					.foregroundStyle(.white)
					.frame(width: 50, height: 50)
					.background(data.style.symbolColor.gradient)
					.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

				VStack(alignment: .leading) {
					Text(data.content.title)
						.font(.title3)
						.fontWeight(.semibold)
					Text(data.content.message)
						.font(.subheadline)
						.foregroundStyle(.primary)
						.lineLimit(3)
				}
				Spacer()

			}
			.padding(15)
			.frame(maxWidth: currentPlatform == .phone ? .infinity : 350)
			.background(Color(.secondarySystemBackground))
			.clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
			.overlay(
				RoundedRectangle(cornerRadius: 25)
					.strokeBorder(.tertiary, lineWidth: 1)
			)
			.shadow(color: .black.opacity(0.05), radius: 10, y: 3)
			.onTapGesture {
				if let onTap = data.onTap {
					onTap()
				}
			}
			// Swipe up to dismiss
			.simultaneousGesture(
				DragGesture(minimumDistance: 10, coordinateSpace: .global)
					.onEnded { value in
						if value.translation.height < 0 {
							onDismiss()
						}
					}
			)
		} else {
			HStack(spacing: 10) {

				Image(systemName: data.style.sfSymbol)
					.font(.body)
					.foregroundStyle(.white)
					.frame(width: 32.5, height: 32.5)
					.background(data.style.symbolColor.gradient)
					.clipShape(Circle())

				VStack(alignment: .center) {
					Text(data.content.title)
						.font(.body)
						.fontWeight(.semibold)
					Text(data.content.message)
						.font(.caption)
						.foregroundStyle(.secondary)
						.lineLimit(1)  // limit to one line in compact mode
				}
				.padding(.trailing, 20)  // for a visual balance
			}
			.padding(10)
			.background(Color(.systemBackground))
			.clipShape(Capsule(style: .circular))
			.overlay(
				Capsule(style: .circular)
					.strokeBorder(.tertiary, lineWidth: 0.75)
			)
			.onTapGesture {
				if let onTap = data.onTap {
					onTap()
				}
			}
			.shadow(color: .black.opacity(0.05), radius: 10, y: 3)
			.simultaneousGesture(
				DragGesture(minimumDistance: 10, coordinateSpace: .global)
					.onEnded { value in
						if value.translation.height < 0 {
							onDismiss()
						}
					}
			)
		}
	}
}

#Preview {
	VStack {
		InAppNotificationView(
			data: InAppNotificationData(
				id: UUID(),
				content: InAppNotificationContent(
					title: "Some Interesting Info", message: "Notification Message"),
				style: InAppNotificationStyle(
					sfSymbol: "pencil.tip.crop.circle", symbolColor: .indigo, size: .normal), onTap: nil),
			onDismiss: {})
		InAppNotificationView(
			data: InAppNotificationData(
				id: UUID(), content: InAppNotificationContent(title: "Error", message: "Error Message"),
				style: InAppNotificationType.error.style,
				onTap: {
					print("Tappy Tap Info!")
				}), onDismiss: {})
		InAppNotificationView(
			data: InAppNotificationData(
				id: UUID(), content: InAppNotificationContent(title: "Info", message: "Info Message"),
				style: InAppNotificationType.info.style,
				onTap: {
					print("Tappy Tap Info!")
				}), onDismiss: {})
		InAppNotificationView(
			data: InAppNotificationData(
				id: UUID(), content: InAppNotificationContent(title: "Failure", message: "Failure Message"),
				style: InAppNotificationStyle(sfSymbol: "xmark.circle", symbolColor: .red, size: .compact),
				onTap: {
					print("Tappy Tap Failure!")
				}), onDismiss: {})
		InAppNotificationView(
			data: InAppNotificationData(
				id: UUID(), content: InAppNotificationContent(title: "Success", message: "Tap for more Info"),
				style: InAppNotificationStyle(
					sfSymbol: "checkmark.circle.fill", symbolColor: .green, size: .compact),
				onTap: {
					print("Tappy Tap Success!")
				}), onDismiss: {})

		InAppNotificationView(
			data: InAppNotificationData(
				id: UUID(), content: InAppNotificationContent(title: "Warning", message: "Warning Message"),
				style: InAppNotificationStyle(
					sfSymbol: "exclamationmark.triangle.fill", symbolColor: .yellow, size: .compact),
				onTap: {
					print("Tappy Tap Warning!")
				}), onDismiss: {})
	}
	.padding(.horizontal)

}
