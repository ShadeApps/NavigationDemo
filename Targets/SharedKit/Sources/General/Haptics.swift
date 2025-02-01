//
//  Haptics.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import UIKit

public class Haptics {

	// Haptics to tell the user a result (success / warning, etc)
	static public func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
		let generator = UINotificationFeedbackGenerator()
		generator.notificationOccurred(type)
	}

	// Haptics to simulate physical impact
	static public func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
		let generator = UIImpactFeedbackGenerator(style: style)
		generator.impactOccurred()
	}
}
