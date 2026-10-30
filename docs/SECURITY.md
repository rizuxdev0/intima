# Sécurité et Confidentialité dans INTIMA

## 1. Modèle de menace et principes

INTIMA applique le principe du **moindre privilège** et de la **défense en profondeur** :
- Les données intimes ne quittent jamais l'appareil.
- Aucun composant analytique ou de tracking (pas de Firebase, pas de Sentry, pas d'API distante).
- Aucune permission réseau (`android.permission.INTERNET`) n'est requise.

## 2. Chiffrement au repos (AES-256-GCM)

- **Algorithme** : AES-256 en mode Galois/Counter Mode (GCM), fournissant à la fois la confidentialité et l'intégrité authentifiée des données.
- **Nonce** : Un nonce aléatoire cryptographiquement fort de 12 octets (96 bits) est généré via un générateur de nombres aléatoires sécurisé (`Random.secure()`) à chaque opération d'écriture.
- **Tag d'authentification** : 16 octets (128 bits) garantissant la non-altération des fichiers.
- **Écriture atomique** : Écriture préalable dans un fichier temporaire (`.tmp`) avant remplacement atomique afin de prévenir toute corruption lors d'un arrêt brutal.

## 3. Gestion des clés et du code PIN

- **Clé de chiffrement** : Stockée dans le Keystore matériel Android (avec SharedPreferences chiffrées) ou le Keychain iOS (`flutter_secure_storage`).
- **Code PIN** : N'est jamais stocké en clair. Il est dérivé via **PBKDF2 avec HMAC-SHA256** sur 100 000 itérations avec un sel aléatoire de 16 octets.
- **Comparaison en temps constant** : Protection contre les attaques par canal auxiliaire (timing attacks).
- **Verrouillage progressif** : Blocage temporaire pendant 60 secondes après 5 tentatives infructueuses consécutives.
- **Biométrie** : Intégration native Touch ID / Face ID / Empreinte digitale via `local_auth`. L'accès par PIN reste toujours disponible en secours.

## 4. Protection contre les fuites visuelles

- **Mode discret** : Remplace les libellés intimes par des dénominations neutres (« Événement personnel »).
- **Notifications discrètes** : Par défaut, le contenu affiche « Tu as un rappel personnel » sans révéler de données intimes sur l'écran verrouillé.

