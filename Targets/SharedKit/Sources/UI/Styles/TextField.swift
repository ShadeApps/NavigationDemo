//
//  TextField.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

let commonTextFieldRadius = 10.0
let commonTextFieldHeight = 50.0
let commonTextFieldFontStyle: Font = .system(.body, weight: .regular)

public struct CommonTextField: TextFieldStyle {

	private let disabled: Bool

	public init(disabled: Bool = false) {
		self.disabled = disabled
	}

	public func _body(configuration: TextField<Self._Label>) -> some View {
		configuration
			.font(commonTextFieldFontStyle)
			.padding()
			.frame(height: commonTextFieldHeight)
			.background(Color(disabled ? .secondarySystemFill : .secondarySystemBackground))
			.foregroundStyle(disabled ? .secondary : .primary)
			.clipShape(RoundedRectangle(cornerRadius: commonTextFieldRadius, style: .continuous))
			.overlay(
				RoundedRectangle(cornerRadius: commonTextFieldRadius)
					.strokeBorder(.tertiary, lineWidth: 1)
			)
			.disabled(disabled)
	}
}

#Preview {
	VStack(spacing: 20) {
		TextField("Test TextField", text: .constant("Hello"))
			.textFieldStyle(CommonTextField())
		TextField("Test TextField", text: .constant("Hello"))
			.textFieldStyle(CommonTextField(disabled: true))

	}
	.padding()

}
