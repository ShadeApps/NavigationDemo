//
//  onAppearAndChange.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

extension View {
	/// Will execute `action()` on appear and when `value` changes.
	@ViewBuilder public func onAppearAndChange<V>(
		of value: V,
		perform action: @escaping () -> Void
	) -> some View where V: Equatable {
        if #available(iOS 17.0, *) {
            self
                .onAppear {
                    action()
                }
                .onChange(of: value) {
                    action()
                }
        } else {
            // Fallback on earlier versions
        }
	}

}

private struct PreviewView: View {

	@State var value: Int = 0

	var body: some View {
		VStack {
			Text("Value: \(value)")
			Button("Increase by one") {
				value += 1
			}
			.onAppearAndChange(of: value) {
				print("New Value: \(value)")
			}
		}
	}
}

#Preview {
	PreviewView()
}
