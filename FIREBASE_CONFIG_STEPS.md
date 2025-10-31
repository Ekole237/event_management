# 🔥 Configuration Firebase - Étapes à Suivre

## ⚠️ Configuration Incomplète

La commande `flutterfire configure` a partiellement échoué. Voici les étapes pour terminer manuellement :

---

## 📱 **Étape 1 : Configuration Android**

### A. Télécharger google-services.json

1. Allez sur https://console.firebase.google.com/project/event-management-200f3/settings/general
2. Sous "Vos applications", trouvez l'app Android : **com.example.event_management**
3. Cliquez sur le bouton "Télécharger google-services.json"
4. Placez le fichier ici : `event_management/android/app/google-services.json`

### B. Récupérer l'API Key Android

Dans la même page Firebase Console :
1. Trouvez la section "SDK Setup and configuration"
2. Sous "Android", copiez la valeur de **apiKey**
3. Ouvrez `event_management/lib/firebase_options.dart`
4. Remplacez `YOUR_ANDROID_API_KEY` par la vraie clé API

**Exemple** :
```dart
apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', // Votre vraie clé
```

---

## 🍎 **Étape 2 : Configuration iOS (Optionnel)**

Si vous voulez tester sur iOS :

1. Dans Firebase Console, ajoutez une app iOS
2. Bundle ID : `com.example.eventManagement`
3. Téléchargez `GoogleService-Info.plist`
4. Ajoutez-le dans Xcode : `event_management/ios/Runner/GoogleService-Info.plist`
5. Mettez à jour l'API Key iOS dans `firebase_options.dart`

---

## 🌐 **Étape 3 : Configuration Web (Optionnel)**

Pour le Web :

1. Dans Firebase Console, ajoutez une app Web
2. Récupérez la configuration Web
3. Mettez à jour les valeurs dans `firebase_options.dart` section `web`

---

## ✅ **Vérification**

Une fois configuré, testez l'app :

```bash
cd event_management
flutter run
```

Si vous voyez l'écran de connexion, c'est bon ! ✅

---

## 🔍 **Informations de votre projet**

- **Project ID** : event-management-200f3
- **Messaging Sender ID** : 1090732408388
- **Storage Bucket** : event-management-200f3.firebasestorage.app
- **Android App ID** : 1:1090732408388:android:0bb44e517fe8c6e112c611

---

## 🆘 **Besoin d'aide ?**

Si vous rencontrez des problèmes :

1. Vérifiez que `google-services.json` est bien dans `android/app/`
2. Vérifiez que l'API Key est correcte dans `firebase_options.dart`
3. Essayez : `flutter clean && flutter pub get`
4. Relancez : `flutter run`

---

## 📚 **Ressources**

- [Firebase Console](https://console.firebase.google.com/project/event-management-200f3)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
