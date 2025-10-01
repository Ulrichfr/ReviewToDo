//
//  SettingsView.swift
//  ReviewToDoAPp
//
//  Created with Claude Code
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var firebaseManager = FirebaseManager.shared
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.mainGradient
                    .ignoresSafeArea()

                AppTheme.darkOverlay
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // User Info
                        if let user = firebaseManager.currentUser {
                            VStack(spacing: 12) {
                                Image(systemName: user.isAnonymous ? "person.fill.questionmark" : "person.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.orange, .pink],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )

                                if user.isAnonymous {
                                    Text("Mode Invité")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)

                                    Text("Créez un compte pour sauvegarder vos données")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                        .multilineTextAlignment(.center)
                                } else {
                                    Text(user.email ?? "Utilisateur")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.top, 20)
                        }

                        // Change Password (only for non-anonymous users)
                        if let user = firebaseManager.currentUser, !user.isAnonymous {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Changer le mot de passe")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)

                                VStack(spacing: 12) {
                                    SecureField("Nouveau mot de passe", text: $newPassword)
                                        .textContentType(.newPassword)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(Color.white.opacity(0.1))
                                        )
                                        .foregroundColor(.white)

                                    SecureField("Confirmer le mot de passe", text: $confirmPassword)
                                        .textContentType(.newPassword)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(Color.white.opacity(0.1))
                                        )
                                        .foregroundColor(.white)

                                    Button(action: changePassword) {
                                        HStack {
                                            if isLoading {
                                                ProgressView()
                                                    .tint(.white)
                                            } else {
                                                Text("Mettre à jour")
                                                    .fontWeight(.semibold)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(AppTheme.buttonGradient)
                                        )
                                        .foregroundColor(.white)
                                    }
                                    .disabled(isLoading || newPassword.isEmpty || confirmPassword.isEmpty)
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(AppTheme.cardSurface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(AppTheme.cardBorder, lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 16)
                        }

                        // Messages
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                        }

                        if !successMessage.isEmpty {
                            Text(successMessage)
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.horizontal, 20)
                        }

                        Spacer()
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Paramètres")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func changePassword() {
        errorMessage = ""
        successMessage = ""

        guard newPassword.count >= 6 else {
            errorMessage = "Le mot de passe doit contenir au moins 6 caractères."
            return
        }

        guard newPassword == confirmPassword else {
            errorMessage = "Les mots de passe ne correspondent pas."
            return
        }

        isLoading = true

        Task {
            do {
                try await firebaseManager.updatePassword(newPassword: newPassword)
                HapticManager.notification(.success)
                successMessage = "Mot de passe mis à jour avec succès !"
                newPassword = ""
                confirmPassword = ""
            } catch {
                HapticManager.notification(.error)
                errorMessage = "Erreur : \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}

#Preview {
    SettingsView()
}
