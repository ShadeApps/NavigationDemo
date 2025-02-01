//
//  CurrentPlatform.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import UIKit

public enum Platform {
	case phone
	case pad
}

/// Convenience wrapper around UIDevice.current.userInterfaceIdiom
/// Note: Code provided by SwiftyLaunch only utilized this function if more than one platform is selected during project generation.
public var currentPlatform: Platform {
	return UIDevice.current.userInterfaceIdiom == .pad ? .pad : .phone
}
