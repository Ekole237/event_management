# Guide de Configuration EventEase

## 🚀 Configuration Rapide

### Prérequis
- Flutter 3.35.7+ installé
- Dart 3.9.0+
- Un compte Firebase
- Android Studio / Xcode (pour émulateurs)

### Étape 1 : Installation des dépendances

```bash
cd event_management
flutter pub get
```

### Étape 2 : Configuration Firebase

#### A. Créer un projet Firebase

1. Aller sur [Firebase Console](https://console.firebase.google.com/)
2. Cliquer sur "Ajouter un projet"
3. Suivre les étapes de création

#### B. Activer les services Firebase

Dans votre projet Firebase, activer :

1. **Authentication**
   - Aller dans "Authentication" > "Sign-in method"
   - Activer "Email/Password"
   - Activer "Google" (fournir SHA-1 pour Android)
   - Activer "Apple" (pour iOS uniquement)

2. **Cloud Firestore**
   - Aller dans "Firestore Database"
   - Créer une base de données (mode test pour commencer)
   - Copier les règles de sécurité du README.md

3. **Storage**
   - Aller dans "Storage"
   - Activer Cloud Storage

4. **Cloud Messaging**
   - Déjà activé par défaut

5. **Analytics**
   - Déjà activé par défaut

#### C. Configurer Firebase dans l'app

##### Option 1 : Utiliser FlutterFire CLI (Recommandé)

```bash
# Installer FlutterFire CLI
dart pub global activate flutterfire_cli

# Se connecter à Firebase
firebase login

# Configurer le projet
flutterfire configure
```

Suivre les instructions et sélectionner votre projet Firebase. Cela générera automatiquement `lib/firebase_options.dart` avec les bonnes configurations.

##### Option 2 : Configuration manuelle

Si FlutterFire CLI ne fonctionne pas, modifier manuellement `lib/firebase_options.dart` :

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'VOTRE_API_KEY_ANDROID',
  appId: 'VOTRE_APP_ID_ANDROID',
  messagingSenderId: 'VOTRE_MESSAGING_SENDER_ID',
  projectId: 'VOTRE_PROJECT_ID',
  storageBucket: 'VOTRE_STORAGE_BUCKET',
);
```

Répéter pour web, ios, macos.

### Étape 3 : Configuration Android

#### A. Ajouter google-services.json

1. Dans Firebase Console, aller dans Paramètres du projet > Général
2. Sous "Vos applications", cliquer sur Android
3. Télécharger `google-services.json`
4. Placer dans `android/app/`

#### B. Configurer le build.gradle

Le fichier `android/app/build.gradle.kts` doit contenir :

```kotlin
android {
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.event_management"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }
}
```

#### C. Obtenir le SHA-1 (pour Google Sign-In)

```bash
cd android
./gradlew signingReport
```

Copier le SHA-1 et l'ajouter dans Firebase Console > Paramètres du projet > Votre application Android.

### Étape 4 : Configuration iOS (Optionnel)

1. Télécharger `GoogleService-Info.plist` depuis Firebase Console
2. L'ajouter dans `ios/Runner/` via Xcode
3. Dans `ios/Runner/Info.plist`, ajouter :

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Nous avons besoin d'accéder à vos photos pour les images d'événements</string>
<key>NSCameraUsageDescription</key>
<string>Nous avons besoin d'accéder à votre caméra pour prendre des photos</string>
```

### Étape 5 : Configurer les règles Firestore

Dans Firebase Console > Firestore > Règles, copier-coller :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
      allow create: if request.auth != null;
    }

    match /events/{eventId} {
      allow read: if resource.data.isPublic == true || request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.organizerId;
    }

    match /participants/{participantId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }

    match /notifications/{notificationId} {
      allow read, update: if request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
  }
}
```

### Étape 6 : Lancer l'application

```bash
# Voir les émulateurs disponibles
flutter devices

# Lancer sur un émulateur spécifique
flutter run -d <device-id>

# Ou simplement
flutter run
```

## 🔧 Commandes Utiles

```bash
# Installer les dépendances
flutter pub get

# Analyser le code
flutter analyze

# Formater le code
flutter format lib/

# Nettoyer et reconstruire
flutter clean && flutter pub get

# Build APK Android
flutter build apk --release

# Build pour iOS
flutter build ios --release

# Voir les packages obsolètes
flutter pub outdated
```

## 📱 Tester l'Application

### Compte de test

Pour tester rapidement, créer un compte avec :
- Email : test@eventease.com
- Password : test123456

### Créer votre premier événement

1. Se connecter
2. Cliquer sur le bouton "Create Event"
3. Remplir les informations
4. Publier l'événement

## 🐛 Résolution de Problèmes

### Erreur : "Dart SDK version"

Si vous voyez une erreur sur la version du SDK, vérifier `pubspec.yaml` :

```yaml
environment:
  sdk: '>=3.9.0 <4.0.0'
```

### Erreur : "Firebase not initialized"

Vérifier que :
1. `firebase_options.dart` existe
2. Les clés API sont correctes
3. Le package `firebase_core` est importé

### Erreur Google Sign-In (Android)

1. Vérifier que SHA-1 est ajouté dans Firebase Console
2. Vérifier que `google-services.json` est dans `android/app/`
3. Rebuild l'app : `flutter clean && flutter run`

### L'app crash au démarrage

1. Vérifier les logs : `flutter logs`
2. Vérifier que toutes les dépendances sont installées
3. Essayer : `flutter clean && flutter pub get && flutter run`

## 📚 Ressources

- [Documentation Flutter](https://docs.flutter.dev/)
- [Documentation Firebase](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [Material Design 3](https://m3.material.io/)

## ✅ Checklist de Configuration

- [ ] Flutter installé et configuré
- [ ] Projet Firebase créé
- [ ] Authentication activée (Email, Google, Apple)
- [ ] Cloud Firestore activé avec règles configurées
- [ ] Storage activé
- [ ] FlutterFire CLI configuré OU firebase_options.dart configuré manuellement
- [ ] google-services.json ajouté (Android)
- [ ] GoogleService-Info.plist ajouté (iOS)
- [ ] SHA-1 ajouté dans Firebase Console (pour Google Sign-In Android)
- [ ] Dépendances installées (`flutter pub get`)
- [ ] App testée sur émulateur/simulateur

## 🎯 Prochaines Étapes

Une fois la configuration terminée :

1. Tester l'authentification
2. Créer un événement de test
3. Tester l'inscription à un événement
4. Vérifier les notifications
5. Tester le mode sombre
6. Personnaliser les thèmes si nécessaire

Bon développement avec EventEase ! 🎉
