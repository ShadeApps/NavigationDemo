//
//  Stack.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

/// This flexible Stack View allows to easily switch between an HStack, VStack or a ZStack
public struct Stack<Content: View>: View {

	public enum StackType {
		case horizontal, vertical, zAxis
	}

	let stackType: StackType
	let spacing: CGFloat?
	let content: () -> Content

	public init(
		_ stackType: StackType,
		spacing: CGFloat? = nil,
		@ViewBuilder content: @escaping () -> Content
	) {
		self.stackType = stackType
		self.spacing = spacing
		self.content = content
	}

	public var body: some View {
		if stackType == .horizontal {
			HStack(spacing: spacing, content: content)
		} else if stackType == .vertical {
			VStack(spacing: spacing, content: content)
		} else {
			ZStack(content: content)
		}
	}
}
