//
//  CheckmarkToggle.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

public struct CheckmarkToggle: View {
	var checked: Bool
	let onToggle: (() -> Void)

	public init(checked: Bool, onToggle: @escaping (() -> Void) = {}) {
		self.checked = checked
		self.onToggle = onToggle
	}

	public var body: some View {
		Image(systemName: checked ? "checkmark.circle.fill" : "circle")
			.fontWeight(.semibold)
			.foregroundStyle(checked ? Color.accentColor : .secondary)
			.accessibilityLabel(Text(checked ? "Checked" : "Unchecked"))
			.imageScale(.large)
			.animation(.easeInOut(duration: 0.15), value: checked)
			.onTapGesture {
				onToggle()
			}
	}
}

public struct CheckToggleStyle: ToggleStyle {
	public func makeBody(configuration: Configuration) -> some View {
		Button {
			configuration.isOn.toggle()
		} label: {
			Label {
				configuration.label
			} icon: {
				CheckmarkToggle(checked: configuration.isOn) {
					configuration.isOn.toggle()
				}
			}
		}
		.buttonStyle(.plain)
	}
}

private struct PreviewView: View {

	@State var isCheckedOne: Bool = false
	@State var isCheckedTwo: Bool = true

	var body: some View {
		VStack(spacing: 20) {
			Toggle("Checkmark Toggle", isOn: $isCheckedOne)
				.toggleStyle(CheckToggleStyle())
				.font(.largeTitle)

			Toggle("Checkmark Toggle", isOn: $isCheckedTwo)
				.toggleStyle(CheckToggleStyle())
				.font(.largeTitle)

		}
	}
}

#Preview {
	PreviewView()
}
