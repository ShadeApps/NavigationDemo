//
//  Color+Extensions.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SwiftUI

extension Color {

	//Hex as Int
	public init(hex: Int, opacity: Double = 1) {
		self.init(
			.sRGB,
			red: Double((hex >> 16) & 0xff) / 255,
			green: Double((hex >> 08) & 0xff) / 255,
			blue: Double((hex >> 00) & 0xff) / 255,
			opacity: opacity
		)
	}

	// Hex as String
	public init(hex: String?, opacity: Double? = nil) {
		let normalizedHexString: String = Color.normalize(hex)
		var ccc: CUnsignedLongLong = 0
		Scanner(string: normalizedHexString).scanHexInt64(&ccc)
		var resultAlpha: CGFloat {
			switch opacity {
				case nil: return ColorMasks.alphaValue(ccc)
				default: return opacity!
			}
		}
		self.init(
			CGColor(
				red: ColorMasks.redValue(ccc),
				green: ColorMasks.greenValue(ccc),
				blue: ColorMasks.blueValue(ccc),
				alpha: resultAlpha))
	}

	public func hexDescription(_ includeAlpha: Bool = false) -> String {
		guard let cgColor = self.cgColor else {
			return "Problem with cgColor"
		}
		guard cgColor.numberOfComponents == 4 else {
			return "Color not RGB."
		}
		guard let components = cgColor.components else {
			return "Problem with cgColor.components"
		}
		let aaa = components.map({ Int($0 * CGFloat(255)) })
		let color = String.init(format: "%02x%02x%02x", aaa[0], aaa[1], aaa[2])
		if includeAlpha {
			let alpha = String.init(format: "%02x", aaa[3])
			return "\(color)\(alpha)"
		}
		return color
	}

	fileprivate enum ColorMasks: CUnsignedLongLong {
		case redMask = 0xff00_0000
		case greenMask = 0x00ff_0000
		case blueMask = 0x0000_ff00
		case alphaMask = 0x0000_00ff

		static func redValue(_ value: CUnsignedLongLong) -> CGFloat {
			return CGFloat((value & redMask.rawValue) >> 24) / 255.0
		}

		static func greenValue(_ value: CUnsignedLongLong) -> CGFloat {
			return CGFloat((value & greenMask.rawValue) >> 16) / 255.0
		}

		static func blueValue(_ value: CUnsignedLongLong) -> CGFloat {
			return CGFloat((value & blueMask.rawValue) >> 8) / 255.0
		}

		static func alphaValue(_ value: CUnsignedLongLong) -> CGFloat {
			return CGFloat(value & alphaMask.rawValue) / 255.0
		}
	}

	fileprivate static func normalize(_ hex: String?) -> String {
		guard var hexString = hex else {
			return "00000000"
		}
		if hexString.hasPrefix("#") {
			hexString = String(hexString.dropFirst())
		}
		if hexString.count == 3 || hexString.count == 4 {
			hexString = hexString.map { "\($0)\($0)" }.joined()
		}
		let hasAlpha = hexString.count > 7
		if !hasAlpha {
			hexString += "ff"
		}
		return hexString
	}
}
