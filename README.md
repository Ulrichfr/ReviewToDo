# ReviewToDo 📱

Une application iOS native pour gérer vos tests de produits tech avec style.

## ✨ Fonctionnalités

### Gestion des tests
- 📋 **Organisation** : Gérez vos tests de produits tech (smartphones, aspirateurs robots, batteries, etc.)
- ✏️ **Édition rapide** : Tap sur une carte pour éditer (Nouveau v1.1.0)
- 🗑️ **Suppression par swipe** : Swipe vers la gauche pour supprimer (Nouveau v1.1.0)
- 🎉 **Animation confetti** : Célébrez chaque test complété avec des confettis colorés (Nouveau v1.1.0)

### Interface & Design
- 🎯 **Priorités visuelles** : Système de priorités avec emojis (🔴 Urgente, 🟠 Élevée, 🟡 Moyenne, 🟢 Faible)
- 📊 **Onglets séparés** : Tests à faire vs tests terminés
- 🔥 **Widget urgent** : Affichage du test le plus urgent avec compteur
- 🎨 **Sélecteur moderne** : Catégories en scroll horizontal tactile (Nouveau v1.1.0)
- 🌙 **Mode sombre** : Interface dark élégante avec gradient
- ✨ **Animations fluides** : Transitions et retours haptiques améliorés (Nouveau v1.1.0)

### Fonctionnalités avancées
- 📸 **Photos de produits** : Ajoutez des photos depuis la caméra, galerie ou web
- 📝 **Notes détaillées** : Ajoutez des notes pour chaque test
- ☁️ **Synchronisation Firebase** : Vos tests synchronisés sur tous vos appareils en temps réel
- 🔐 **Authentification multi-plateforme** : Connexion email, anonyme, ou compte Apple/Google
- 🔄 **Sync temps réel** : Les modifications apparaissent instantanément sur tous vos appareils
- 🔑 **Gestion des mots de passe** : Récupération et changement de mot de passe intégrés (Nouveau v1.3.0)
- ⚙️ **Paramètres utilisateur** : Interface dédiée pour gérer votre compte (Nouveau v1.3.0)

## 🛠 Technologies

- **SwiftUI** : Interface utilisateur native
- **Firebase** : Backend et authentification
  - **Firebase Auth** : Authentification sécurisée multi-méthodes
  - **Cloud Firestore** : Base de données temps réel
  - **Firebase Analytics** : Statistiques d'utilisation
- **iOS 26** : Dernières APIs Apple

## 📱 Captures d'écran

L'app inclut :
- Liste interactive avec animations
- Système de priorités coloré
- Widget de test urgent
- Interface TabView native
- Mode sombre par défaut

## 🚀 Installation

1. Clonez le projet
2. Ouvrez `ReviewToDoAPp.xcodeproj` dans Xcode
3. Ajoutez votre fichier `GoogleService-Info.plist` depuis Firebase Console
4. Lancez sur simulateur ou appareil iOS

## 📦 Versions

### v1.3.0 (Actuelle)
- 🔑 **Gestion complète des mots de passe** :
  - Récupération par email via "Mot de passe oublié ?"
  - Changement de mot de passe depuis les Paramètres
  - Messages de confirmation et d'erreur clairs
- ⚙️ **Écran Paramètres** : Nouvelle interface pour gérer votre compte
- ⚠️ **Warning mode invité** : Bandeau d'avertissement pour les comptes anonymes
- 🎓 **Onboarding** : Écran de bienvenue pour les nouveaux utilisateurs (comptes non-anonymes uniquement)
- 🎯 **Produits pré-remplis** : Exemples automatiques pour les comptes invités seulement

### v1.2.0
- ☁️ **Synchronisation Firebase** : Vos données synchronisées en temps réel sur tous vos appareils
- 🔐 **Authentification sécurisée** : Connexion par email/mot de passe, anonyme, ou via Apple/Google
- 🔄 **Sync temps réel** : Modifications instantanées sur tous vos appareils
- 🚪 **Bouton de déconnexion** : Déconnectez-vous facilement depuis l'app
- 📊 **Firebase Analytics** : Suivi des statistiques d'utilisation

### v1.1.0
- ✨ Édition des produits par tap sur carte
- 🗑️ Suppression par swipe vers la gauche
- 🎉 Animation confetti lors de la complétion
- 📱 Sélecteur de catégories horizontal moderne
- 🎨 Améliorations UI et animations
- 🐛 Corrections de bugs du bouton +

### v1.0.0
- 🚀 Version initiale
- Interface de base avec TabView
- Gestion des tests et priorités

## 📋 À venir

- 📱 Version iPad optimisée
- 💻 Version macOS
- 🍎 Connexion avec Apple
- 🔍 Connexion avec Google
- 📊 Statistiques et rapports avancés
- 🔔 Notifications et rappels

---

**Créé avec ❤️ et Claude Code**