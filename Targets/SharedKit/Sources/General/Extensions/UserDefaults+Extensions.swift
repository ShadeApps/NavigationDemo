//
//  UserDefaults+Extensions.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import Foundation

/// Call this function to reset all userDefaults
/// Currently only used in DeveloperSettingsView
extension UserDefaults {
	public func clear() {
		guard let domainName = Bundle.main.bundleIdentifier else {
			return
		}
		removePersistentDomain(forName: domainName)
		synchronize()
		print("[LOCALSTORAGE] CLEARED USERDEFAULTS")
	}
}
