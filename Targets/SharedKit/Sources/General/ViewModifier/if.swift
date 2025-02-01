//
//  if.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

//NOTE: Please use this modifier cautiously. It is not recommended to use this modifier, as it may lead to unexpected SwiftUI behaviour
//But sometimes we just need to break the rules a little bit...

extension View {
	/// Applies the given transform if the given condition evaluates to `true`.
	/// - Parameters:
	///   - condition: The condition to evaluate.
	///   - transform: The transform to apply to the source `View`.
	/// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
	@ViewBuilder public func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}
}

#Preview {
	VStack {
		Text("This is shown on all versions")

		Text("This has a red background on versions above 16.4")
			///Example of using the if modifier
			.if(
				{
					if #available(iOS 16.4, *) {
						return true
					}
					return false
				}()
			) { view in
				view.background(Color.red)
			}
	}
}
