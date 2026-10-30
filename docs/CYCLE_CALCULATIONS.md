# Moteur de Calcul du Cycle Menstruel

## 1. Principes et Éthique

Le moteur de calcul (`CycleCalculationEngine`) est complètement isolé de l'interface graphique. Il repose sur des principes scientifiques éprouvés tout en restant humble quant aux limites des estimations statistiques.

> **Avertissement médical impératif** : Le calendrier ne constitue pas un moyen de contraception fiable à lui seul. L'application affiche explicitement les limites et refuse d'affirmer qu'un jour est « garanti sans risque ».

## 2. Algorithmes implémentés

### 2.1 Durée du cycle
La durée d'un cycle est calculée comme l'intervalle en jours entre le premier jour d'un cycle ($D_n$) et le premier jour du cycle suivant ($D_{n+1}$) :
$$\text{Durée} = D_{n+1} - D_n$$
Les valeurs aberrantes (< 15 jours ou > 60 jours) sont filtrées pour éviter de fausser les moyennes.

### 2.2 Durée des règles
Calculée par différence inclusive entre la date de fin et la date de début :
$$\text{Durée des règles} = (\text{Date fin} - \text{Date début}) + 1$$

### 2.3 Moyenne et Variabilité
- **Moyenne** : Moyenne arithmétique des durées observées.
- **Variabilité** : Écart-type d'échantillon des durées de cycles. Une variabilité supérieure à 7 jours signale des cycles irréguliers et déclenche une mention d'incertitude.

### 2.4 Estimations
- **Prochaines règles** : Dernier premier jour + moyenne des cycles observés.
- **Ovulation estimée** : Dernier premier jour + (moyenne des cycles - 14 jours, phase lutéale standard).
- **Fenêtre de fertilité** : De 5 jours avant l'ovulation jusqu'à 1 jour après l'ovulation (prise en compte de la durée de vie des spermatozoïdes et de l'ovocyte).
- **Fiabilité** : Un minimum de 3 cycles est requis pour que l'estimation soit considérée comme fiable (`isReliable: true`).

