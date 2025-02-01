//
//  GetPlistEntry.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import Foundation

public enum PlistReadError: String, LocalizedError {
	case noPlist = "PlistReadError: No .plist file found"
	case noEntry = "PlistReadError: No entry found in Property List"

	public var errorDescription: String? { self.rawValue }
}

/// Get a string value from property list
/// Note: only for property lists in the main app bundle
/// Will throw `PlistReadError`in case of a fail
public func getPlistEntry(
	_ plistEntry: String,
	in plistName: String
) throws -> String {
	if let path = Bundle.main.path(forResource: plistName, ofType: "plist"),
		let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject]
	{
		if let retrievedEntry = dict[plistEntry] as? String, !retrievedEntry.isEmpty {
			return retrievedEntry
		}
		throw PlistReadError.noEntry
	}
	throw PlistReadError.noPlist
}
