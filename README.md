# Développement

## Pour exécuter n'importe quel script qui utilise firestore

    Installer google cloud sdk (pas besoin d'être admin sur la machine)
    https://cloud.google.com/sdk/docs/install

    gcloud init

    gcloud auth application-default login

A partir de là il est possible de lancer n'importe quel exécutable python (cli, dump_stats, main, etc)

## Pour vérifier le packaging avant de déployer sur gcloud

    gcloud beta code dev

    docker run -e PORT=80 -p 80:80 --rm -it $(docker build -q .)

# Architecture

On utilise firestore pour enregistrer les statistiques. Cette partie marche bien.

## Version 1 : Un cli pour chaque élèves 

Problèmes

- Cauchemardesque à installer sur les postes d'élèves (parce qu'on a besoin de deux dépendances)
- Difficile à lancer
- Les élèves ne comprennent pas comment utiliser
- En salle de classe on a parfois du mal à télécharger ses stats (je n'ai pas complètement investigué)

## Version 2 : Ajout d'un serveur en python avec une UI en html

Pour éviter les problèmes de la version 1, j'ai créé une seconde version avec un serveur en python et une UI en html (pas de javascript)

Le serveur tourne sur google cloud engine. Les algorithmes tournent sur le serveur. Quand on augmente la taille du problème on obtient des erreurs de dépassement de capacité de la part de google cloud engine, et ce pour tous les clients.

Cette architecture est complètement inutilisable par les élèves,
il reste la partie cli qui fonctionne pour l'enseignant, pour faire des démos ou pour fabriquer des stats (et ensuite les étudier dans excel)

## RESTE A FAIRE - Version 3 : web statique

Une application web avec rien à installer sur le client, et pas de runtime sur le serveur.
Les algorithmes tournent dans les navigateurs des élèves. Les statistiques sont stockées comme d'habitude sur firestore

Choix du framework frontend :

- svelte parce que je connais
- elm parce que c'est top,
  - une librairie firestore possible : https://github.com/IzumiSy/elm-firestore
  - Pour l'app elm même soit https://github.com/ryan-haskell/elm-spa soit https://elm.land/
