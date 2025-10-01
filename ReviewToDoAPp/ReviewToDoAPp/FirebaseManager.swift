//
//  FirebaseManager.swift
//  ReviewToDoAPp
//
//  Created with Claude Code
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import Combine

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()

    var auth: Auth!
    var db: Firestore!

    @Published var currentUser: User?
    @Published var isSignedIn = false

    private init() {
        // L'initialisation se fait dans setup() après FirebaseApp.configure()
    }

    func setup() {
        auth = Auth.auth()
        db = Firestore.firestore()

        // Observer l'état d'authentification
        let _ = auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isSignedIn = user != nil
            }
        }
    }

    // MARK: - Authentication

    func signInAnonymously() async throws {
        try await auth.signInAnonymously()
    }

    func signIn(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        try await auth.createUser(withEmail: email, password: password)
    }

    func signOut() throws {
        try auth.signOut()
    }

    func sendPasswordReset(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }

    func updatePassword(newPassword: String) async throws {
        guard let user = currentUser else {
            throw NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])
        }
        try await user.updatePassword(to: newPassword)
    }

    // MARK: - Firestore

    func getUserTestsCollection() -> CollectionReference? {
        guard let userId = currentUser?.uid else { return nil }
        return db.collection("users").document(userId).collection("tests")
    }
}
