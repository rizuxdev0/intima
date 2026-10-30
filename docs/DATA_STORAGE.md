# Stockage et Persistance des Données

## 1. Organisation logique des fichiers

Les données sont enregistrées dans le répertoire privé de l'application (`getApplicationSupportDirectory()`) :

```text
intima_data/
├── database/
│   ├── profile.enc               # Profil utilisateur chiffré
│   ├── partners.enc              # Liste des partenaires chiffrée
│   ├── encounters.enc            # Journal des rencontres chiffré
│   ├── menstrual_cycles.enc      # Cycles et symptômes chiffrés
│   ├── reminders.enc             # Configuration des rappels chiffrée
│   ├── preferences.enc           # Préférences utilisateur chiffrées
│   └── metadata.json             # Version du schéma (non sensible)
└── exports/
    └── backup_<timestamp>.intima.enc # Sauvegarde chiffrée exportable
```

## 2. Format des fichiers chiffrés (.enc)

Chaque fichier `.enc` est composé de :
1. **Nonce (12 octets)** : Aléatoire, unique à chaque écriture.
2. **Ciphertext + GCM Tag (16 octets)** : Données JSON sérialisées chiffrées en AES-256.

Toute modification manuelle ou corruption d'un seul octet entraîne une erreur d'intégrité (`EncryptionException`) et empêche la lecture de données corrompues.

## 3. Sauvegarde et Restauration

- **Export** : Crée une archive locale chiffrée avec en-tête de version (`INTIMA_BACKUP_V1`).
- **Import** : Vérifie l'intégrité avant d'appliquer les données.
- **Effacement d'urgence** : Disponible depuis le Centre de Confidentialité, permettant d'effacer tous les fichiers de données et toutes les clés cryptographiques de l'appareil.

