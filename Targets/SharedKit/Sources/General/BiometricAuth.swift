//
//  BiometricAuth.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import LocalAuthentication

public class BiometricAuth {

	static public func authenticate() async -> Bool {
		let context = LAContext()
		var error: NSError?

		// check whether authentication is possible
		if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
			do {
				//return the result of the authentication
				return try await context.evaluatePolicy(
					.deviceOwnerAuthentication, localizedReason: "Authenticate to see the content.")
			} catch {
				print(
					"Unhandled biometric auth error: \(error.localizedDescription)"
				)
				return false
			}
		} else {
			// No Password, Biometrics, or Apple Watch to authenticate -> always return true
			return true
		}
	}

	/// Perform an action after a successful biometric authentication.
	static public func executeIfSuccessfulAuth(
		_ onSuccessClosure: () -> Void,
		otherwise onFailedClosure: (() -> Void)? = nil
	) async {
		guard await authenticate() else {
			if let onFailedClosure {
				onFailedClosure()
			}
			return
		}
		onSuccessClosure()
	}

	/// Async closure version (both success and failed are async).
	/// Perform an action after a successful biometric authentication.
	static public func executeIfSuccessfulAuth(
		_ onSuccessClosure: () async -> Void,
		otherwise onFailedClosure: (() async -> Void)? = nil
	) async {
		guard await authenticate() else {
			if let onFailedClosure {
				await onFailedClosure()
			}
			return
		}
		await onSuccessClosure()
	}

	/// Async closure version (failed is async).
	/// Perform an action after a successful biometric authentication.
	static public func executeIfSuccessfulAuth(
		_ onSuccessClosure: () -> Void,
		otherwise onFailedClosure: (() async -> Void)? = nil
	) async {
		guard await authenticate() else {
			if let onFailedClosure {
				await onFailedClosure()
			}
			return
		}
		onSuccessClosure()
	}

	/// Async closure version (onSuccess is async).
	/// Perform an action after a successful biometric authentication.
	static public func executeIfSuccessfulAuth(
		_ onSuccessClosure: () async -> Void,
		otherwise onFailedClosure: (() -> Void)? = nil
	) async {
		guard await authenticate() else {
			if let onFailedClosure {
				onFailedClosure()
			}
			return
		}
		await onSuccessClosure()
	}

}
