//
//  IsPreview.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import Foundation

///Will return whether the code is running in a SwiftUI Preview (For Xcode Previews)
public var isPreview: Bool {
	return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
