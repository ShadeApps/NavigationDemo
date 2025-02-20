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

public var currentPlatform: Platform {
	return UIDevice.current.userInterfaceIdiom == .pad ? .pad : .phone
}
