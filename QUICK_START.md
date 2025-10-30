# 🚀 EventEase - Démarrage Rapide

## En 5 Minutes ⚡

### 1. Prérequis (1 min)
```bash
flutter --version  # Vérifier que Flutter est installé
```

### 2. Installation (1 min)
```bash
cd event_management
flutter pub get
```

### 3. Configuration Firebase (2 min)

**Option rapide** : Utiliser FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
firebase login
flutterfire configure
```

**OU modifier manuellement** `lib/firebase_options.dart` avec vos clés Firebase.

### 4. Lancer l'App (1 min)
```bash
flutter run
```

## 🎯 Test Rapide

1. **Créer un compte** : Utilisez n'importe quel email
2. **Créer un événement** : Cliquez sur le FAB "Create Event"
3. **Tester le calendrier** : Onglet Calendrier
4. **Activer le mode sombre** : Paramètres > Theme > Dark

## 📁 Structure du Projet

```
event_management/
├── lib/
│   ├── core/              # Configuration app
│   ├── features/          # Fonctionnalités
│   │   ├── auth/         # Authentification
│   │   ├── events/       # Gestion événements
│   │   ├── notifications/ # Notifications
│   │   └── settings/     # Paramètres
│   └── shared/           # Code partagé
│       ├── models/       # Modèles de données
│       ├── services/     # Services Firebase
│       └── providers/    # Riverpod providers
```

## 🔑 Fonctionnalités Principales

- ✅ Authentification (Email, Google, Apple)
- ✅ CRUD Événements complet
- ✅ Calendrier interactif
- ✅ Gestion participants
- ✅ Notifications in-app
- ✅ Mode sombre
- ✅ Multi-plateforme

## 📚 Documentation

- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Configuration détaillée
- [README.md](README.md) - Documentation complète
- [FEATURES_SUMMARY.md](FEATURES_SUMMARY.md) - Liste des fonctionnalités
- [CLAUDE.md](CLAUDE.md) - Guide pour développement

## 🐛 Problèmes Courants

**App ne démarre pas** :
```bash
flutter clean
flutter pub get
flutter run
```

**Erreur Firebase** :
- Vérifier `firebase_options.dart`
- Vérifier que Firebase est configuré

**Erreur Google Sign-In (Android)** :
- Ajouter SHA-1 dans Firebase Console
- Vérifier `google-services.json`

## 💡 Prochaines Étapes

1. Configurer Firebase avec un vrai projet
2. Ajouter vos règles Firestore (voir SETUP_GUIDE.md)
3. Tester sur un appareil réel
4. Personnaliser les couleurs dans `lib/core/theme/app_theme.dart`

## 📞 Support

Des questions ? Voir la documentation complète ou ouvrir une issue sur GitHub.

---

**Bon développement ! 🎉**
