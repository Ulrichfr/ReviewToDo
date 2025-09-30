//
//  ReviewToDoAPpApp.swift
//  ReviewToDoAPp
//
//  Created by Ulrich Rozier on 30/09/2025.
//

import SwiftUI
import FirebaseCore

@main
struct ReviewToDoAPpApp: App {
    @StateObject private var firebaseManager = FirebaseManager.shared

    init() {
        FirebaseApp.configure()
        FirebaseManager.shared.setup()
    }

    var body: some Scene {
        WindowGroup {
            if firebaseManager.isSignedIn {
                ContentView()
            } else {
                AuthView()
            }
        }
    }
}
