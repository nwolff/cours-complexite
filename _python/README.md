# Déployé ici

https://cours-complexite-bppjye22la-oa.a.run.app/

# Développement

## Pour exécuter n'importe quel script qui utilise firestore

    gcloud init

    gcloud auth application-default login

A partir de là il est possible de lancer n'importe quel exécutable python (cli, dump_stats, main, etc)

## Pour vérifier le packaging avant de déployer sur gcloud

    gcloud beta code dev

    docker run -e PORT=80 -p 80:80 --rm -it $(docker build -q .)

# Architecture

On utilise firestore pour enregistrer les statistiques. Cette partie marche bien.

## Version 1 : Un cli que chaque élève installe

Problèmes

- Cauchemardesque à installer sur les postes d'élèves (parce qu'on a besoin de deux dépendances)
- Difficile à lancer
- Les élèves ne comprennent pas comment utiliser
- En salle de classe on a parfois du mal à télécharger ses stats (je n'ai pas complètement investigué)

## Version 2 : Serveur en python avec une UI en html

Pour éviter les problèmes de la version 1, j'ai créé une seconde version avec un serveur en python et une UI en html (pas de javascript)

Le serveur tourne sur google cloud engine
Les algorithmes tournent sur le serveur. Quand on augmente la taille du problème on obtient des erreurs de dépassement de capacité de la part de google cloud engine, et ce pour tous les clients

Cette architecture est complètement inutilisable et le résultat est encore moins utilisable que la version 1

