//
//  AuthView.swift
//  ReviewToDoAPp
//
//  Created with Claude Code
//

import SwiftUI

struct AuthView: View {
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showEmailAuth = false
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false

    var body: some View {
        ZStack {
            AppTheme.mainGradient
                .ignoresSafeArea()

            AppTheme.darkOverlay
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Logo et titre
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("ReviewToDo")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Gérez vos tests de produits\nsur tous vos appareils")
                        .font(.body)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Options de connexion
                VStack(spacing: 16) {
                    if showEmailAuth {
                        emailAuthView
                    } else {
                        mainAuthView
                    }

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }

                    Text("Vos données seront synchronisées\nentre tous vos appareils ☁️")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Views

    private var mainAuthView: some View {
        VStack(spacing: 12) {
            Button(action: { showEmailAuth = true; isSignUp = false }) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .font(.title3)
                    Text("Se connecter avec email")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.buttonGradient)
                )
                .foregroundColor(.white)
            }
            .disabled(isLoading)

            Button(action: { showEmailAuth = true; isSignUp = true }) {
                HStack {
                    Image(systemName: "person.badge.plus.fill")
                        .font(.title3)
                    Text("Créer un compte")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
                .foregroundColor(.white)
            }
            .disabled(isLoading)

            Button(action: signInAnonymously) {
                HStack {
                    Image(systemName: "person.fill.questionmark")
                        .font(.caption)
                    Text("Continuer sans compte")
                        .font(.caption)
                }
                .foregroundColor(AppTheme.textSecondary)
                .padding(.top, 8)
            }
            .disabled(isLoading)
        }
    }

    private var emailAuthView: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.1))
                )
                .foregroundColor(.white)

            SecureField("Mot de passe", text: $password)
                .textContentType(isSignUp ? .newPassword : .password)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.1))
                )
                .foregroundColor(.white)

            Button(action: isSignUp ? signUp : signIn) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isSignUp ? "Créer mon compte" : "Se connecter")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.buttonGradient)
                )
                .foregroundColor(.white)
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty)

            Button(action: {
                showEmailAuth = false
                email = ""
                password = ""
                errorMessage = ""
            }) {
                Text("Retour")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - Actions

    private func signInAnonymously() {
        isLoading = true
        errorMessage = ""

        Task {
            do {
                try await firebaseManager.signInAnonymously()
                HapticManager.notification(.success)
            } catch {
                HapticManager.notification(.error)
                errorMessage = "Erreur de connexion. Vérifiez votre connexion internet."
            }
            isLoading = false
        }
    }

    private func signIn() {
        isLoading = true
        errorMessage = ""

        Task {
            do {
                try await firebaseManager.signIn(email: email, password: password)
                HapticManager.notification(.success)
            } catch {
                HapticManager.notification(.error)
                errorMessage = "Email ou mot de passe incorrect."
            }
            isLoading = false
        }
    }

    private func signUp() {
        isLoading = true
        errorMessage = ""

        guard password.count >= 6 else {
            errorMessage = "Le mot de passe doit contenir au moins 6 caractères."
            isLoading = false
            return
        }

        Task {
            do {
                try await firebaseManager.signUp(email: email, password: password)
                HapticManager.notification(.success)
            } catch {
                HapticManager.notification(.error)
                errorMessage = "Impossible de créer le compte. Email déjà utilisé ?"
            }
            isLoading = false
        }
    }
}

#Preview {
    AuthView()
}
