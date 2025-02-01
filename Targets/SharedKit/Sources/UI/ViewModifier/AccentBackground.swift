//
//  AccentBackground.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

struct AccentBackground: ViewModifier {

	let strong: Bool

	func body(content: Content) -> some View {
		content
			.background(
				LinearGradient(
					colors: [
						Color.accentColor.opacity(strong ? 0.2 : 0.075),
						Color(uiColor: .secondarySystemBackground),
					], startPoint: .topLeading,
					endPoint: .bottomTrailing)
			)
	}
}

extension View {
	public func accentBackground(strong: Bool = false) -> some View {
		modifier(AccentBackground(strong: strong))
	}
}

#Preview {
	HeroView(sfSymbolName: "person.fill", title: "Example View")
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.accentBackground(strong: true)
}
