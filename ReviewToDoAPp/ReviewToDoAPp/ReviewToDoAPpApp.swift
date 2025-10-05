//
//  ReviewToDoAPpApp.swift
//  ReviewToDoAPp
//
//  Created by Ulrich Rozier on 30/09/2025.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            QuickActionService.shared.shouldShowAddSheet = (shortcutItem.type.hasSuffix(".newTest"))
        }

        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        QuickActionService.shared.shouldShowAddSheet = (shortcutItem.type.hasSuffix(".newTest"))
        completionHandler(true)
    }
}

@main
struct ReviewToDoAPpApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var firebaseManager = FirebaseManager.shared
    @StateObject private var quickActionService = QuickActionService.shared

    init() {
        FirebaseApp.configure()
        FirebaseManager.shared.setup()
    }

    var body: some Scene {
        WindowGroup {
            if firebaseManager.isSignedIn {
                ContentView()
                    .environmentObject(quickActionService)
            } else {
                AuthView()
            }
        }
    }
}
