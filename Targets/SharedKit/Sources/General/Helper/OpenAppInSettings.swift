//
//  OpenAppInSettings.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

/// Will open the settings app with our app's settings
/// Always returns false.
@discardableResult
public func openAppInSettings() -> Bool {
	UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
	/// Just for convenience, so we can use the same function type as in RequestType.requestAction
	return false
}
