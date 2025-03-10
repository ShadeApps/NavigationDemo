//
//  App.swift
//  NavigationDemo
//
//  Created by Sergey Grishchev on 01/02/2025.
//

import SharedKit
import SwiftUI
import UIKit

@main
struct MainApp: App {

	@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

	init() { }

	var body: some Scene {
		WindowGroup {
            ContentView(viewModel: ContentViewViewModel(networkManager: NetworkManager()))
				.modifier(ShowRequestSheetWhenNeededModifier())
		}
	}
}

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {

		return true
	}

	func application(
		_ application: UIApplication,
		configurationForConnecting connectingSceneSession: UISceneSession,
		options: UIScene.ConnectionOptions
	)
		-> UISceneConfiguration
	{
		let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
		if connectingSceneSession.role == .windowApplication {
			configuration.delegateClass = SceneDelegate.self
		}
		return configuration
	}

}

final class SceneDelegate: NSObject, ObservableObject, UIWindowSceneDelegate {

	var keyWindow: UIWindow?
	var secondaryWindow: UIWindow?

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		if let windowScene = scene as? UIWindowScene {
			setupSecondaryOverlayWindow(in: windowScene)
		}

		UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor.init(
			named: "AccentColor")
	}

	func setupSecondaryOverlayWindow(in scene: UIWindowScene) {
		let secondaryViewController = UIHostingController(
			rootView:
				EmptyView()
				.frame(maxWidth: .infinity, maxHeight: .infinity)

				.modifier(ShowInAppNotificationsWhenCalledModifier())

		)
		secondaryViewController.view.backgroundColor = .clear

		let secondaryWindow = PassThroughWindow(windowScene: scene)
		secondaryWindow.rootViewController = secondaryViewController
		secondaryWindow.isHidden = false
		self.secondaryWindow = secondaryWindow
	}
}

class PassThroughWindow: UIWindow {
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

		guard let hitView = super.hitTest(point, with: event) else { return nil }

		return rootViewController?.view == hitView ? nil : hitView
	}
}
