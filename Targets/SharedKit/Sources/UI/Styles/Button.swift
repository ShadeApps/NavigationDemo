//
//  Button.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

let commonButtonRadius = 10.0
let commonButtonHeight = 50.0
let commonButtonFontStyle: Font = .system(.title3, weight: .semibold)

public struct CTAButtonStyle: ButtonStyle {

	public init() {}

	public func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(commonButtonFontStyle)
			.frame(height: commonButtonHeight)
			.frame(maxWidth: .infinity)
			.foregroundStyle(Color.white)
			.background(
				(configuration.role == .destructive || configuration.role == .cancel)
					? Color.red.gradient : Color.accentColor.gradient
			)
			.clipShape(RoundedRectangle(cornerRadius: commonButtonRadius, style: .continuous))
			.scaleEffect(configuration.isPressed ? 0.975 : 1.0)
			.animation(.interactiveSpring, value: configuration.isPressed)
			.hoverEffect()
	}
}

extension ButtonStyle where Self == CTAButtonStyle {
	public static func cta() -> Self {
		CTAButtonStyle()
	}
}

public struct SecondaryButtonStyle: ButtonStyle {

	public init() {}

	public func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(commonButtonFontStyle)
			.frame(height: commonButtonHeight)
			.frame(maxWidth: .infinity)
			.foregroundStyle(
				(configuration.role == .destructive || configuration.role == .cancel)
					? Color.red : Color.accentColor
			)
			.background(.quinary)
			.clipShape(RoundedRectangle(cornerRadius: commonButtonRadius, style: .continuous))
			.overlay(
				RoundedRectangle(cornerRadius: commonButtonRadius)
					.strokeBorder(.quaternary, lineWidth: 0.5)
			)
			.scaleEffect(configuration.isPressed ? 0.975 : 1.0)
			.animation(.interactiveSpring, value: configuration.isPressed)
			.hoverEffect()
	}
}

extension ButtonStyle where Self == SecondaryButtonStyle {
	public static func secondary() -> Self {
		SecondaryButtonStyle()
	}
}

#Preview {
	VStack(spacing: 20) {
		VStack {
			Button("CTA Button") {}
				.buttonStyle(.cta())

			Button("Destructive CTA Button", role: .destructive) {}
				.buttonStyle(.cta())
		}
		VStack {
			Button("SecondaryButton") {}
				.buttonStyle(.secondary())

			Button("Destructive Secondary Button", role: .destructive) {}
				.buttonStyle(.secondary())
		}
	}
	.padding()
}
