# ReviewToDo

Application iOS de gestion de tests de produits tech avec synchronisation Firebase.

## 📱 Fonctionnalités

### Version 1.5.0 (Octobre 2025)
- **Filtrage par priorité** : Filtrez vos tests par niveau de priorité (Urgentes 🔴, Élevées 🟠, Moyennes 🟡, Faibles 🟢)
- **Barre de filtres moderne** : Interface intuitive avec capsules sélectionnables
- **Confirmation de suppression** : Protection contre la suppression accidentelle des tests urgents
- **Déconnexion** : Nouveau bouton de déconnexion dans les paramètres avec confirmation
- **État vide redesigné** : Messages adaptatifs selon le filtre actif

### Version 1.4.1
- Écran d'explication pour les notifications
- Produits de test améliorés

### Version 1.4.0
- Dates d'échéance pour les tests
- Système de notifications push avec Firebase Cloud Messaging
- Rappels automatiques avant échéance

### Version 1.3.0
- Gestion des mots de passe
- Paramètres utilisateur avancés

### Version 1.2.0
- Synchronisation Firebase Firestore
- Authentification utilisateur (email/password)
- Données synchronisées en temps réel

### Version 1.1.0
- Gestion des tests de produits tech
- Niveaux de priorité (🔴 Urgent, 🟠 Élevé, 🟡 Moyen, 🟢 Faible)
- Notes et commentaires
- Interface moderne avec thème sombre

## 🛠 Technologies

- **SwiftUI** : Framework UI natif Apple
- **Firebase** :
  - Firestore : Base de données NoSQL en temps réel
  - Authentication : Gestion des utilisateurs
  - Cloud Messaging : Notifications push
- **UserNotifications** : Notifications locales iOS
- **Combine** : Programmation réactive

## 📦 Installation

### Prérequis
- Xcode 15.0+
- iOS 17.0+
- Compte Firebase configuré

### Configuration Firebase
1. Télécharger `GoogleService-Info.plist` depuis la console Firebase
2. Placer le fichier à la racine du projet
3. Vérifier que le fichier est bien inclus dans les targets

### Build
```bash
# Ouvrir le projet
open ReviewToDo.xcodeproj

# Ou builder via command line
xcodebuild -project ReviewToDo.xcodeproj -scheme ReviewToDo -configuration Debug
```

## 🎨 Design

L'application utilise un thème sombre moderne avec :
- Gradient bleu/violet pour l'identité visuelle
- Design glass morphism pour les cartes
- Animations fluides et retours haptiques
- Typographie system (SF Pro)

## 📝 Structure du projet

```
ReviewToDo/
├── ContentView.swift          # Vue principale avec liste de tests
├── SettingsView.swift         # Paramètres utilisateur
├── OnboardingView.swift       # Écran d'onboarding
├── DataManager.swift          # Gestionnaire de données Firestore
├── FirebaseManager.swift      # Authentification Firebase
├── NotificationManager.swift  # Gestion des notifications
├── Models/
│   └── ProductTest.swift      # Modèle de données test produit
└── Utils/
    ├── AppTheme.swift         # Thème et couleurs
    └── HapticManager.swift    # Retours haptiques
```

## 🔐 Sécurité

- Authentification Firebase sécurisée
- Rules Firestore configurées pour l'accès utilisateur uniquement
- Pas de données sensibles stockées localement
- Déconnexion avec confirmation

## 🚀 Prochaines fonctionnalités

- [ ] Export des tests en PDF/CSV
- [ ] Mode hors ligne avec synchronisation
- [ ] Partage de tests entre utilisateurs
- [ ] Statistiques et graphiques
- [ ] Tags et catégories personnalisées
- [ ] Recherche et tri avancés

## 📄 License

Propriétaire - Tous droits réservés

## 👤 Auteur

Ulrich Rozier

## 🔗 Liens

- GitHub: [https://github.com/Ulrichfr/ReviewToDo](https://github.com/Ulrichfr/ReviewToDo)
