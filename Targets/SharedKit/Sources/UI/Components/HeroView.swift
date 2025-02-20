//
//  HeroView.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

public enum HeroViewSize {
	case small
	case large
}

public struct HeroView: View {

	private let sfSymbolName: String
	private let title: LocalizedStringKey
	private let subtitle: LocalizedStringKey?
	private let size: HeroViewSize

	@State var bounceOnChangeOfThisValue: Bool

	public init(
		sfSymbolName: String,
		title: LocalizedStringKey,
		subtitle: LocalizedStringKey? = nil,
		size: HeroViewSize = .large,
		bounceOnAppear: Bool = false
	) {
		self.sfSymbolName = sfSymbolName
		self.title = title
		self.subtitle = subtitle
		self.size = size
		self._bounceOnChangeOfThisValue = State(initialValue: bounceOnAppear)
	}

	public var body: some View {
		VStack {
            if #available(iOS 17.0, *) {
                Image(systemName: sfSymbolName)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.accentColor.gradient)
                    .font(.system(size: size == .large ? 125 : 75, weight: .semibold))
                    .padding(.bottom, size == .large ? 10 : 5)
                    .symbolEffect(.bounce, value: bounceOnChangeOfThisValue)
            } else {
                Image(systemName: sfSymbolName)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.accentColor.gradient)
                    .font(.system(size: size == .large ? 125 : 75, weight: .semibold))
                    .padding(.bottom, size == .large ? 10 : 5)
            }

			Text(title)
				.font(.largeTitle)
				.bold()
				.multilineTextAlignment(.center)

			if let subtitle = subtitle {
				Text(subtitle)
					.font(.callout)
					.multilineTextAlignment(.center)
					.foregroundStyle(.secondary)
			}
		}
		.onAppear {
			Task {
				if bounceOnChangeOfThisValue {
					try? await Task.sleep(for: .seconds(0.2))
					bounceOnChangeOfThisValue.toggle()
				}
			}
		}
	}
}

private struct PreviewView: View {

	var body: some View {
		VStack {
			HeroView(
				sfSymbolName: "envelope.badge",
				title: "Check your Inbox.",
				subtitle: "An email with a verification link\nwas sent to your@email.com",
				bounceOnAppear: true
			)
		}
	}

}

#Preview { PreviewView() }
