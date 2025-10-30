# EventEase - Application de Gestion d'Événements

EventEase est une application mobile intuitive développée avec Flutter qui permet d'organiser, gérer et suivre facilement des événements personnels ou professionnels.

## 📱 Fonctionnalités

### Authentification
- ✅ Connexion par email/mot de passe
- ✅ Inscription utilisateur
- ✅ Connexion avec Google
- ✅ Connexion avec Apple ID
- 🔄 Réinitialisation de mot de passe (en cours)

### Gestion des Événements
- ✅ Création d'événements avec informations complètes
- ✅ Modification et suppression d'événements
- ✅ Duplication d'événements
- ✅ Statuts d'événements (brouillon, publié, terminé, annulé)
- ✅ Catégorisation (conférence, atelier, meetup, etc.)
- 🔄 Upload d'images pour les événements
- 🔄 Recherche et filtres

### Participants
- ✅ Inscription aux événements
- ✅ Gestion des statuts de participation (en attente, confirmé, refusé)
- ✅ Suivi des présences
- ✅ Statistiques de participation
- 🔄 Notifications automatiques

### Interface Utilisateur
- ✅ Tableau de bord avec événements à venir
- ✅ Liste des événements personnels
- ✅ Design Material 3 moderne
- ✅ Mode sombre/clair
- 🔄 Vue calendrier interactive
- 🔄 Notifications push

### Administration
- 🔄 Dashboard analytique
- 🔄 Gestion des utilisateurs
- 🔄 Statistiques globales

## 🚀 Installation et Configuration

### Prérequis
- Flutter SDK 3.9.4 ou supérieur
- Dart 3.9.4 ou supérieur
- Un compte Firebase
- Android Studio / Xcode (pour développement natif)

### Étapes d'installation

1. **Cloner le repository**
```bash
cd event_management
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configurer Firebase**

#### Créer un projet Firebase
1. Aller sur [Firebase Console](https://console.firebase.google.com/)
2. Créer un nouveau projet
3. Activer les services suivants :
   - Authentication (Email/Password, Google, Apple)
   - Cloud Firestore
   - Firebase Storage
   - Cloud Messaging
   - Analytics

#### Installer FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

#### Configurer Firebase pour votre app
```bash
flutterfire configure
```

Cela générera automatiquement le fichier `lib/firebase_options.dart` avec vos configurations.

4. **Configuration Android**

Modifier `android/app/build.gradle.kts` :
```kotlin
android {
    defaultConfig {
        minSdk = 21
        targetSdk = 34
    }
}
```

5. **Configuration iOS**

Modifier `ios/Runner/Info.plist` pour ajouter les permissions :
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to upload event images</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take event photos</string>
```

6. **Configurer Google Sign-In**

#### Android
Le fichier `google-services.json` est automatiquement généré par FlutterFire CLI.

#### iOS
1. Ajouter `GoogleService-Info.plist` dans `ios/Runner/`
2. Dans Xcode, ajouter le URL Scheme Google

7. **Lancer l'application**
```bash
flutter run
```

## 📁 Structure du Projet

```
lib/
├── core/
│   ├── constants/        # Constantes de l'app
│   ├── theme/           # Thèmes et styles
│   ├── utils/           # Utilitaires
│   └── router/          # Configuration des routes
├── features/
│   ├── auth/           # Authentification
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── events/         # Gestion des événements
│   ├── participants/   # Gestion des participants
│   ├── notifications/  # Notifications
│   ├── admin/         # Administration
│   └── settings/      # Paramètres
├── shared/
│   ├── models/        # Modèles de données
│   ├── widgets/       # Widgets réutilisables
│   ├── services/      # Services (Firebase, etc.)
│   └── providers/     # Providers Riverpod
└── main.dart         # Point d'entrée
```

## 🎨 Design

L'application utilise Material Design 3 avec :
- Une palette de couleurs moderne (Indigo/Purple)
- Support du mode sombre
- Animations fluides
- Interface responsive

## 🔧 Technologies Utilisées

- **Framework**: Flutter 3.9.4
- **Langage**: Dart 3.9.4
- **State Management**: Riverpod 2.6.1
- **Backend**: Firebase
  - Authentication
  - Cloud Firestore
  - Storage
  - Cloud Messaging
  - Analytics
- **UI Components**:
  - Material Design 3
  - Cached Network Image
  - Table Calendar
- **Build Tools**: build_runner

## 📊 Base de Données Firestore

### Collections

#### `users`
```javascript
{
  email: string,
  displayName: string,
  photoUrl: string?,
  role: "admin" | "organizer" | "participant",
  createdAt: timestamp,
  updatedAt: timestamp?,
  isActive: boolean
}
```

#### `events`
```javascript
{
  title: string,
  description: string,
  startDate: timestamp,
  endDate: timestamp,
  location: string,
  imageUrl: string?,
  category: string,
  status: "draft" | "published" | "completed" | "cancelled",
  organizerId: string,
  organizerName: string,
  maxParticipants: number,
  currentParticipants: number,
  createdAt: timestamp,
  updatedAt: timestamp?,
  tags: array,
  isPublic: boolean
}
```

#### `participants`
```javascript
{
  eventId: string,
  userId: string,
  userName: string,
  userEmail: string,
  userPhotoUrl: string?,
  status: "pending" | "confirmed" | "declined" | "attended" | "absent",
  registeredAt: timestamp,
  updatedAt: timestamp?,
  notes: string?
}
```

#### `notifications`
```javascript
{
  userId: string,
  title: string,
  body: string,
  type: string,
  eventId: string?,
  createdAt: timestamp,
  isRead: boolean,
  data: object?
}
```

## 🔐 Sécurité

### Règles Firestore

Ajoutez ces règles dans Firebase Console > Firestore > Règles :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
      allow create: if request.auth != null;
    }

    // Events collection
    match /events/{eventId} {
      allow read: if resource.data.isPublic == true || request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.organizerId;
    }

    // Participants collection
    match /participants/{participantId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }

    // Notifications collection
    match /notifications/{notificationId} {
      allow read, update: if request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
  }
}
```

## 🚧 Développement en Cours

- [ ] Écran de création d'événement complet
- [ ] Écran de détails d'événement
- [ ] Vue calendrier avec table_calendar
- [ ] Système de notifications push
- [ ] Dashboard administrateur
- [ ] Gestion des utilisateurs (admin)
- [ ] Upload d'images avec Firebase Storage
- [ ] Recherche et filtres avancés
- [ ] Rappels automatiques
- [ ] Export de données

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Analyse du code
flutter analyze

# Vérifier les dépendances obsolètes
flutter pub outdated
```

## 📱 Build Production

### Android
```bash
flutter build apk --release
# ou
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📝 License

Ce projet est sous licence MIT.

## 👨‍💻 Auteur

EventEase - Application de gestion d'événements

## 📞 Support

Pour toute question ou support, veuillez ouvrir une issue sur le repository GitHub.

---

**Note**: Cette application est actuellement en développement actif. Certaines fonctionnalités peuvent être incomplètes ou en cours d'implémentation.
