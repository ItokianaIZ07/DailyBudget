# SpendWise

## Présentation

**SpendWise** est une application mobile de gestion des dépenses personnelles développée avec **Flutter et Dart**. Le projet a pour objectif de faciliter le suivi des dépenses quotidiennes en proposant une interface simple permettant d'enregistrer, consulter et organiser les opérations financières.

## Fonctionnalités

L'application permet notamment de gérer les dépenses et les catégories associées. L'utilisateur peut ajouter, modifier ou supprimer une dépense, puis consulter son historique.

L'historique dispose de plusieurs outils permettant de retrouver plus facilement les dépenses, notamment la **recherche par mot-clé** et les **filtres par année, mois et catégorie**. Les montants sont également calculés automatiquement afin de fournir une vue synthétique des dépenses.

Une fonctionnalité de **limite mensuelle par catégorie** est également intégrée afin de permettre un meilleur contrôle des dépenses.

## Architecture technique

SpendWise utilise une architecture organisée autour de plusieurs responsabilités afin de faciliter la maintenance et l'évolution du projet.

Les données sont représentées par des modèles, tandis que les repositories assurent l'accès à la base de données et que les services regroupent la logique métier. L'interface est divisée en différentes fonctionnalités et composants réutilisables.

Cette organisation permet notamment de séparer l'interface utilisateur de la gestion des données.

## Stockage des données

L'application utilise **SQLite** comme base de données locale, avec le package `sqflite`. Les données restent ainsi disponibles directement sur l'appareil et l'application peut fonctionner sans dépendre d'un serveur distant.

## Technologies utilisées

| Technologie | Utilisation |
|---|---|
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/flutter/flutter-original.svg" width="30"> **Flutter** | Développement de l'application |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/dart/dart-original.svg" width="30"> **Dart** | Langage de programmation |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/sqlite/sqlite-original.svg" width="30"> **SQLite / sqflite** | Stockage local |
| **Material Design** | Composants et conception de l'interface |
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/gradle/gradle-original.svg" width="30"> **Gradle** | Configuration et génération Android |

## Évolution du projet

SpendWise est actuellement centré sur la gestion et le suivi des dépenses. Des fonctionnalités telles que la gestion des **revenus mensuels** et des **charges fixes** sont prévues pour une prochaine évolution du projet.

À terme, l'objectif est de faire évoluer l'application d'un simple gestionnaire de dépenses vers un outil permettant d'avoir une vision plus globale de sa situation budgétaire.
